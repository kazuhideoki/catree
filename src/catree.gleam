import argv
import gleam/io

pub fn main() -> Nil {
  let args = argv.load().arguments
  echo args

  Nil
}
