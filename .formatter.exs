[
  inputs: [
    "mix.exs",
    "lib/**/*.{ex,exs}",
    "test/**/*.{ex,exs}"
  ],
  locals_without_parens: [
    # Kernel
    inspect: 1,
    inspect: 2,

    # Phoenix
    plug: 1,
    plug: 2,
    action_fallback: 1,
    render: 2,
    render: 3,
    render: 4,
    redirect: 2,
    socket: :*,
    get: :*,
    post: :*,
    put: :*,
    resources: :*,
    pipe_through: :*,
    delete: :*,
    forward: :*,
    channel: :*,
    transport: :*,

    # Ecto Schema
    field: 2,
    field: 3,
    belongs_to: 2,
    belongs_to: 3,
    has_one: 2,
    has_one: 3,
    has_many: 2,
    has_many: 3,
    embeds_one: 2,
    embeds_one: 3,
    embeds_many: 2,
    embeds_many: 3,
    many_to_many: 2,
    many_to_many: 3,
    add: 3,

    # Ecto Query
    from: 2,

    # Tests
    assert: 2,
    assert: 3,
    on_exit: 1
  ],
  line_length: 120
]
