module Api
  class ErrorResponse < RuntimeError
    def self.code
      404
    end
  end

  class NotFound < ErrorResponse; end
  class Conflict < ErrorResponse; end
  class MethodNotAllowed < ErrorResponse; end
end