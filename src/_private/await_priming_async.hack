/** sgml-stream is MIT licensed, see /LICENSE. */
namespace HTL\SGMLStream\_Private;

use namespace HH\Asio;

/** Wait for all priming work, then propagate the first failure in snippet order. */
async function await_priming_async(
  vec<Awaitable<void>> $awaitables,
)[defaults]: Awaitable<void> {
  await AwaitAllWaitHandle::fromVec($awaitables);
  foreach ($awaitables as $awaitable) {
    Asio\result($awaitable);
  }
}
