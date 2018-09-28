class RemoteExchangeLog < ApplicationRecord


  enum status: {
      success: 1,
      failed:0,
      pending:2
  }

  enum method: {
      get: 1,
      post: 2,
      patch: 3
  }

end
