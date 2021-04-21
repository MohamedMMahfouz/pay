module Pay
  module Accept
    class Error < Pay::Error
      delegate :message, to: :cause
    end
  end
end
