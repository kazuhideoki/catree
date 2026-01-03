import argv
import catree/paths
import simplifile

pub fn main() -> Nil {
  let args = argv.load().arguments
  let assert Ok(cwd) = simplifile.current_directory()

  let paths = paths.convert_to_absolute_paths(args, cwd)

  echo paths

  Nil
}
