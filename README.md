# XCUID

eliXir [CUID](https://github.com/ericelliott/cuid).

Collision-resistant ids optimized for horizontal scaling and binary search lookup performance.

This project is a more modern and optimized implementation compare to [duailibe/cuid](https://github.com/duailibe/cuid) which is no longer maintained AFAIK.

## Usage

Add `xcuid` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:xcuid, "~> 0.1.0"}
  ]
end
```

Run `mix deps.get`, then generate a CUID is simple:

```elixir
XCUID.generate() # => cka3hpvst29dw1m12hzwblxd5
```

If you want to start multiple generator you can do
```elixir
{:ok, pid} = XCUID.start(name: :generator_1)
XCUID.generate(pid) #=> cka3hpvst29dw1m12hzwblxd5
```

## Why not UUID v4?

Refer to the [original project](https://github.com/ericelliott/cuid#motivation) for the original motivation of CUID. Personally I use this instead of UUID v4 because:

- CUID is monotonically increasing (due to the timestamp) where UUID v4 (because it is completely random) is not. In addition to the benefits mentioned in the original project, monotonically increasing ID can be used to implement cursor based pagination and UUID can not.
- CUID is easier to add prefix compare to UUID, for example `acct_cka3hpvst29dw1m12hzwblxd5`. This is especially the case when used with Ecto and Postgres. In this case the DB column will be of type UUID (basically hexdecimal digits) so you can't store the prefix with the UUID. You will have to use custom Ecto.Type to do the conversion which is a pain. You can argue that you could just store the prefix and the UUID as string, but in that case it is much longer than a CUID and take more space to store. 32 characters (UUID) vs 25 character (CUID).
- Can be used as html ids any anywhere where things must start with a letter, where as UUID can't because it can start with number.
- Another minor thing is that the dashes in UUID makes selecting UUID not as smooth as CUID, because in a lot of environments for example in the browser or terminal when you double click to select a UUID it won't highlight the entire thing because dash are word breaks. Obviously you can remove the dashes when displaying or use some front-end magic, but that is extra work where CUID just works out of the box.

One disadvantage of CUID is that it take more space, UUID is 16 bytes if stored as hexdecimal, where as CUID is at least 25 bytes. However you can could save some space by not storing an extra `inserted_at` column because that is already included in CUID. If we subtract that 8 byte for timestamp then technically it is just 1 byte more than UUID which is a reasonable price to pay for getting the above advantages.

## Performance

I have optimized the generation code to the best of my knowledge. Currently it can generate ~250k CUIDs per second on my MBP (Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz). If you want even better performance you can pre-generate them in batches.

## Breakdown

** c - h72gsb32 - 0000 - udoc - l363eofy **

The groups, in order, are:

- `c` identifies this as a cuid, and allows you to use it in html entity ids. This will be changed to `d` on May 25 2059. See the Others section for detail.
- `h72gsb32` is the timestamp in millisecond
- `0000` is a counter. A single process might generate the same random string. The weaker the pseudo-random source, the higher the probability. That problem gets worse as processors get faster. So this counter is an attempt to solve the problem. The counter will roll over if the value gets too big. (i.e from `zzzz` back to `0000`).
- `udoc` is a fingerprint, the first two characters are based on the OS process ID and the next two are based on the hostname.
- `l363eofy` a random string generated using `:rand.uniform` with a cryptographically strong seed.

## Others

This [issue](https://github.com/ericelliott/cuid/issues/108) in the original javascript version is fixed in XCUID by changing all CUID to start with `d` instead of `c` after the roll over time which is `2_821_109_907_456` in unix timestamp.

## Credits

- Eric Elliott (author of [original JavaScript version](https://github.com/ericelliott/cuid))
- Lucas Duailibe (author of the original [elixir cuid](https://github.com/duailibe/cuid))
- Roy Bao
