import gleeunit
import gleeunit/should
import gleam/xml.{Document, Node, Text}

pub fn main() {
  gleeunit.main()
}

pub fn empty_tag_test() {
  "<br/>"
  |> xml.parse
  |> should.equal(Ok(Document(root: Node("br", [], []))))
  "<  br  /  >"
  |> xml.parse
  |> should.equal(Ok(Document(root: Node("br", [], []))))
  "<strong></strong>"
  |> xml.parse
  |> should.equal(Ok(Document(root: Node("strong", [], []))))
}

pub fn attrs_test() {
  "<br foo=\"bar\"/>"
  |> xml.parse
  |> should.equal(Ok(Document(root: Node("br", [#("foo", "bar")], []))))

  "<br foo=\"bar\" choo=\"char\"/>"
  |> xml.parse
  |> should.equal(Ok(Document(root: Node(
    "br",
    [#("foo", "bar"), #("choo", "char")],
    [],
  ))))

  "<  br  foo=\"bar\"  choo=\"char\"  /  >"
  |> xml.parse
  |> should.equal(Ok(Document(root: Node(
    "br",
    [#("foo", "bar"), #("choo", "char")],
    [],
  ))))
}

pub fn children_test() {
  "<p>email</p>"
  |> xml.parse
  |> should.equal(Ok(Document(root: Node("p", [], [Text("email")]))))
  "<p><input /></p>"
  |> xml.parse
  |> should.equal(Ok(Document(root: Node("p", [], [Node("input", [], [])]))))
  "<p>email<input /></p>"
  |> xml.parse
  |> should.equal(Ok(Document(root: Node(
    "p",
    [],
    [Text("email"), Node("input", [], [])],
  ))))
}

pub fn nested_test() {
  "<note>
<to>Tove</to>
<from>Jani</from>
<heading>Reminder</heading>
<body>Don't forget me this weekend!</body>
</note>"
  |> xml.parse
  |> should.equal(Ok(Document(root: Node(
    "note",
    [],
    [
      Node("to", [], [Text("Tove")]),
      Node("from", [], [Text("Jani")]),
      Node("heading", [], [Text("Reminder")]),
      Node("body", [], [Text("Don't forget me this weekend!")]),
    ],
  ))))
}
