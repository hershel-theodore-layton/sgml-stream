/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\Tests;

use namespace Facebook\HHAST;
use namespace HH\Lib\{File, Str, Vec};
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

final class MigrationTest extends HackTest {
  public async function testMigrationAsync(): Awaitable<void> {
    $migration = new UserElementMigration(__DIR__);
    await Vec\map_async(
      vec[
        __DIR__.'/migration-targets/using-namespace-interfaces.hack',
        __DIR__.'/migration-targets/using-namespace-sgml-stream.hack',
        __DIR__.'/migration-targets/using-namespaces-only.hack',
        __DIR__.'/migration-targets/using-types-only.hack',
      ],
      async ($path) ==> {
        $code = await HHAST\from_file_async(HHAST\File::fromPath($path))
          |> $migration->migrateFile($path, $$)->getCode()
          |> Str\replace($$, '\\Source;', '\\Expect;');

        $file = File\open_read_write(
          Str\strip_suffix($path, '.hack').'.expect.hack',
          File\WriteMode::OPEN_OR_CREATE,
        );
        using $file->closeWhenDisposed();
        using $file->tryLockx(File\LockType::EXCLUSIVE);
        if ($file->getSize() === 0) {
          return await $file->writeAllAsync($code);
        }

        $expected = await $file->readAllAsync();
        expect($code)->toEqual(
          $expected,
          '%s migration changed since last test run.',
          $path,
        );
      },
    );
  }
}
