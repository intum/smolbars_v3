module Smolbars
  class Template
    def initialize(context, fn)
      @context, @fn = context, fn
    end

    def call(*args, **kwargs)
      if args.length == 0
        invocation = "%s(%s)" % [@fn, kwargs.to_json]
      else
        invocation = "%s(%s)" % [@fn, args.first.to_json]
      end
      @context.eval(invocation)
    end
  end
end