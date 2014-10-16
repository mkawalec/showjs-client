{struct, subtype, Str, enums, maybe} = require 'tcomb'

ID = subtype Str, (s) -> s.length == 15

module.exports = do
  Comment: struct do
    authorID: ID
    slideID: Str
    body: Str
    inReplyTo: maybe ID
    sharingStatus: enums.of 'private all master everyone'
