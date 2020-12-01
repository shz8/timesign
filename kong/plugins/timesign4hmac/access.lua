local constants = require "kong.constants"
local sha256 = require "resty.sha256"
local openssl_hmac = require "resty.openssl.hmac"
local utils = require "kong.tools.utils"
local get_header           = kong.request.get_header


local ngx = ngx
local kong = kong
local error = error
local time = ngx.time
local abs = math.abs
local decode_base64 = ngx.decode_base64
local encode_base64 = ngx.encode_base64
local parse_time = ngx.parse_http_time
local re_gmatch = ngx.re.gmatch
local ipairs = ipairs
local fmt = string.format
local md5                  = ngx.md5
local timestamp            = require "kong.tools.timestamp"


local SIGNATURE_NOT_VALID = "HMAC signature cannot be verified"
local SIGNATURE_NOT_SAME = "HMAC signature does not match"

local function validate_signature(sign_params)
  local mysign = string.lower(md5(sign_params.privateKey..sign_params.time))
  local sign = string.lower(sign_params.sign)
  if mysign ~= sign then
    kong.log.err(mysign.."与"..sign.."不匹配")
    return false, sign.."签名sign不匹配。测试：privateKey="..sign_params.privateKey..";sign="..mysign.."clock_skew："..sign_params.clock_skew 
  end
  return true
end


local function load_credential_into_memory(username)
  local key, err = kong.db.hmacauth_credentials:select_by_username(username)
  if err then
    return nil, err
  end
  return key
end


local function load_credential(username)
  local credential, err
  if username then
    local credential_cache_key = kong.db.hmacauth_credentials:cache_key(username)
    credential, err = kong.cache:get(credential_cache_key, nil,
                                     load_credential_into_memory,
                                     username)
  end

  if err then
    return error(err)
  end

  return credential
end

local function do_authentication(conf)  
  --privateKey  
  local signkey = "sign"
  local timekey = "time"
  local appkey = "appcode"

  local sign = get_header(signkey)
  local time = get_header(timekey)
  local appcode = get_header(appkey)
  
  local query = kong.request.get_query()

  if sign == "" or sign == nil then
    sign = query[signkey]
  end

  if time == "" or time == nil then
    time = query[timekey]
  end
  
  if appcode == "" or appcode == nil then
    appcode = query[appkey]
  end

  if sign == "" or sign == nil then
    kong.log.err("缺少header/url参数sign")
    return kong.response.error(500, "缺少header/url参数sign")
  end

  if time == "" or time == nil then
    kong.log.err("缺少header/url参数time")
    return kong.response.error(500, "缺少header/url参数time")
  end
  
  if appcode == "" or appcode == nil then
    kong.log.err("缺少header/url参数appcode")
    return kong.response.error(500, "缺少header/url参数appcode")
  end

  local atime = tonumber(time)
  if atime == nil then
    kong.log.err("参数time必须为数字")
    return kong.response.error(500, "参数time必须为数字")
  end

  local timediff = timestamp.get_utc() / 1000 - atime

  
  local timeperiod = conf.clock_skew or 120

  if timediff < -1*timeperiod or timediff > timeperiod then
    kong.log.err("time已过期")
    return kong.response.error(500, "time已过期") --..TableToStr(conf)
  end



  -- retrieve hmac parameter from Proxy-Authorization header
  local sign_params = {sign = sign, time = time, appcode = appcode,clock_skew = timeperiod }

  -- validate signature
  local credential = load_credential(sign_params.appcode)
  if not credential then
    kong.log.debug("failed to retrieve credential for ", sign_params.appcode)
    return false, { status = 401, message = "根据appcode=" .. appcode .. "未找到应用" }
  end

  sign_params.privateKey = credential.secret
  local ok, errinfo = validate_signature(sign_params)
  if not ok then
    return false, { status = 401, message = errinfo }
  end

  return true
end


local _M = {}


function _M.execute(conf)

  local ok, err = do_authentication(conf)
  if not ok then
    return kong.response.error(err.status, err.message, err.headers)
  end
end


return _M
