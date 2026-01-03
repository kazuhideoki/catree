import argv
import catree/paths
import catree/renderer
import catree/target_finder
import gleam/list
import simplifile

// plan
//
// ✅ input_paths -> target_file_paths -> print
//
// TODO
// - ignore
// - renderer test
pub fn main() -> Nil {
  let args = argv.load().arguments
  let assert Ok(cwd) = simplifile.current_directory()

  let absolute_paths = paths.convert_to_absolute_paths(args, cwd)

  // io.println("🔶 absolute_paths:")
  // echo absolute_paths

  let target_file_paths =
    target_finder.get_target_file_paths(
      absolute_paths,
      target_finder.GetTargetFilePathsDeps(
        simplifile.read_directory,
        simplifile.is_file,
      ),
    )

  // io.println("🔶 target_file_paths:")
  // echo target_file_paths

  list.each(target_file_paths, fn(path) {
    renderer.print_file(
      path,
      renderer.PrintFileDeps(renderer.read_file, renderer.read_extension),
    )
  })

  Nil
}
