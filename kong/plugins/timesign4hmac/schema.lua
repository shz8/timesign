local typedefs = require "kong.db.schema.typedefs"

return {
  name = "timesign4hmac",
  fields = {
    { consumer = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { checkPath = {
            type = "array",
            required = true,
            elements = { type = "string" },
            default = {"*"},
          }, },
          { whitePath = {
            type = "array",
            elements = { type = "string" },
            default = {},
          }, },
          { clock_skew = { type = "number", default = 120, gt = 0 }, },
        },
      },
    },
  },
}
