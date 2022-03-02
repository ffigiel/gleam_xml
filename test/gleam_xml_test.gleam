import gleeunit
import gleeunit/should
import gleam/xml.{Document, Node, Text}

pub fn main() {
  gleeunit.main()
}

pub fn empty_tag_test() {
  "<br/>"
  |> xml.parse
  |> should.equal(Ok(Document([], Node("br", [], []))))
  "<  br  /  >"
  |> xml.parse
  |> should.equal(Ok(Document([], Node("br", [], []))))
  "<strong></strong>"
  |> xml.parse
  |> should.equal(Ok(Document([], Node("strong", [], []))))
}

pub fn attrs_test() {
  "<br foo=\"bar\"/>"
  |> xml.parse
  |> should.equal(Ok(Document([], Node("br", [#("foo", "bar")], []))))

  "<br foo=\"bar\" choo=\"char\"/>"
  |> xml.parse
  |> should.equal(Ok(Document(
    [],
    Node("br", [#("foo", "bar"), #("choo", "char")], []),
  )))

  "<  br  foo=\"bar\"  choo=\"char\"  /  >"
  |> xml.parse
  |> should.equal(Ok(Document(
    [],
    Node("br", [#("foo", "bar"), #("choo", "char")], []),
  )))
}

pub fn children_test() {
  "<p>email</p>"
  |> xml.parse
  |> should.equal(Ok(Document([], Node("p", [], [Text("email")]))))
  "<p><input /></p>"
  |> xml.parse
  |> should.equal(Ok(Document([], Node("p", [], [Node("input", [], [])]))))
  "<p>email<input /></p>"
  |> xml.parse
  |> should.equal(Ok(Document(
    [],
    Node("p", [], [Text("email"), Node("input", [], [])]),
  )))
}

pub fn nested_test() {
  "<note>
<to>Tove</to>
<from>Jani</from>
<heading>Reminder</heading>
<body>Don't forget me this weekend!</body>
</note>"
  |> xml.parse
  |> should.equal(Ok(Document(
    [],
    Node(
      "note",
      [],
      [
        Node("to", [], [Text("Tove")]),
        Node("from", [], [Text("Jani")]),
        Node("heading", [], [Text("Reminder")]),
        Node("body", [], [Text("Don't forget me this weekend!")]),
      ],
    ),
  )))
}

pub fn metadata_test() {
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<Error><Code>AccessDenied</Code><Message>Access Denied.</Message><Resource>/</Resource><RequestId>16D89EA0BE27450B</RequestId><HostId>bd6a9fc8-4cf4-457a-88d3-ab3c770724be</HostId></Error>"
  |> xml.parse
  |> should.equal(Ok(Document(
    [#("version", "1.0"), #("encoding", "UTF-8")],
    Node(
      "Error",
      [],
      [
        Node("Code", [], [Text("AccessDenied")]),
        Node("Message", [], [Text("Access Denied.")]),
        Node("Resource", [], [Text("/")]),
        Node("RequestId", [], [Text("16D89EA0BE27450B")]),
        Node("HostId", [], [Text("bd6a9fc8-4cf4-457a-88d3-ab3c770724be")]),
      ],
    ),
  )))
}
