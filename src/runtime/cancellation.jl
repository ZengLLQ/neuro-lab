module Cancellation

export CancellationToken, is_cancelled, request_cancel!

"""
    CancellationToken

Thread-safe cooperative cancellation token using Julia's Atomic types.
"""
mutable struct CancellationToken
    cancelled::Threads.Atomic{Bool}

    CancellationToken() = new(Threads.Atomic{Bool}(false))
end

function is_cancelled(token::CancellationToken)::Bool
    return token.cancelled[]
end

function request_cancel!(token::CancellationToken)
    token.cancelled[] = true
end

end # module Cancellation
