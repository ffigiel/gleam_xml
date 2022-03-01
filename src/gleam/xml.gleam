import gleam/io
import string/parser.{Error, Parser, drop, keep}
import gleam/string
import gleam/list
import gleam/order.{Gt, Lt}
import gleam/io

pub type Document {
  Document(root: Tree)
}

pub type Tree {
  Node(tag: String, attrs: List(#(String, String)), children: List(Tree))
  Text(String)
}

pub fn parse(input: String) -> Result(Document, Error) {
  parser.run(input, document_parser())
}

/// parse an xml document
fn document_parser() -> Parser(Document) {
  node_parser()
  |> parser.map(fn(tree) { Document(tree) })
}

/// parse contents of an xml element
fn tree_parser() -> Parser(Tree) {
  parser.one_of([node_parser(), text_parser()])
}

/// parse an xml element
fn node_parser() -> Parser(Tree) {
  parser.succeed2(fn(tag, attrs) { debug("node", #(tag, attrs)) })
  |> drop(parser.whitespace())
  |> keep(tag_parser())
  |> drop(parser.whitespace())
  |> keep(attrs_parser())
  |> drop(parser.whitespace())
  |> parser.then(fn(a) {
    debug("then", a)
    let #(tag, attrs) = a
    children_parser(tag)
    |> parser.map(fn(children) {
      debug("children", children)
      Node(tag, attrs, children)
    })
  })
}

/// parse an element's tag name
/// `<strong`
fn tag_parser() -> Parser(String) {
  parser.succeed(fn(a) { debug("tag", a) })
  |> drop(parser.string("<"))
  |> drop(parser.whitespace())
  |> keep(keyword_parser())
}

/// parse a keyword like element name or an attribute
fn keyword_parser() -> Parser(String) {
  parser.succeed2(fn(a, b) { debug("keyword", string.concat([a, b])) })
  |> keep(parser.take_if(is_alpha))
  |> keep(parser.take_while(is_alpha_or_digit))
}

/// parse zero or more attributes
fn attrs_parser() -> Parser(List(#(String, String))) {
  parser.many(attr_parser(), parser.whitespace())
}

/// parse an attribute and its value
/// `foo="bar"`
fn attr_parser() -> Parser(#(String, String)) {
  parser.succeed2(fn(a, b) { debug("attr", #(a, b)) })
  |> keep(keyword_parser())
  |> drop(parser.string("=\""))
  |> keep(parser.take_while(fn(s) { s != "\"" }))
  |> drop(parser.string("\""))
}

/// parse the rest of an element
fn children_parser(tag: String) -> Parser(List(Tree)) {
  parser.one_of([some_children_parser(tag), none_children_parser()])
}

/// parse element contents and its closing tag
/// `> (optional children) </tag>`
fn some_children_parser(tag: String) -> Parser(List(Tree)) {
  parser.succeed(fn(a) { debug("some_children", a) })
  |> drop(parser.string(">"))
  // FIXME parsing gets stuck around here
  |> keep(parser.many(tree_parser(), parser.whitespace()))
  |> drop(parser.string("<"))
  |> drop(parser.whitespace())
  |> drop(parser.string("/"))
  |> drop(parser.whitespace())
  |> drop(parser.string(tag))
  |> drop(parser.whitespace())
  |> drop(parser.string(">"))
}

/// parse a self-closing tag
/// `/>`
fn none_children_parser() -> Parser(List(Tree)) {
  parser.succeed([])
  |> drop(parser.string("/"))
  |> drop(parser.whitespace())
  |> drop(parser.string(">"))
}

/// parse text inside an element
fn text_parser() -> Parser(Tree) {
  parser.take_if_and_while(fn(s) { s != "<" })
  |> parser.map(Text)
}

pub fn is_alpha_or_digit(s: String) -> Bool {
  is_alpha(s) || is_digit(s)
}

fn is_alpha(s: String) -> Bool {
  let s = string.lowercase(s)
  case string.compare(s, "a"), string.compare(s, "z") {
    Lt, _ -> False
    _, Gt -> False
    _, _ -> True
  }
}

fn is_digit(s: String) -> Bool {
  let s = string.lowercase(s)
  case string.compare(s, "0"), string.compare(s, "9") {
    Lt, _ -> False
    _, Gt -> False
    _, _ -> True
  }
}

fn debug(label: String, value: a) -> a {
  display(#(label, value))
  value
}

external fn display(a: a) -> Nil =
  "erlang" "display"
