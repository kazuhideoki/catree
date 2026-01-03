import argv
import catree/paths

pub fn main() -> Nil {
  let args = argv.load().arguments
  let cwd = paths.get_current_directory()

  let paths = paths.convert_to_absolute_paths(args, cwd)

  echo paths

  Nil
}
