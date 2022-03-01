import gleeunit
import gleeunit/should
import gleam/xml.{Document, Node, Text}

pub fn main() {
  gleeunit.main()
}

fn basic_test() {
  "<br/>"
  |> xml.parse
  |> should.equal(Ok(Document(root: Node("br", [], []))))
  "<  br  /  >"
  |> xml.parse
  |> should.equal(Ok(Document(root: Node("br", [], []))))
}

fn attrs_test() {
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

pub fn closing_test() {
  "<strong></strong>"
  |> xml.parse
  |> should.equal(Ok(Document(root: Node("strong", [], []))))
}

fn note_test() {
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
