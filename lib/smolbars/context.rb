require 'handlebars/source'
require 'mini_racer'
require 'securerandom'

module Smolbars
  class Context
    JS_ESCAPE_MAP = {
      '\\'    => '\\\\',
      "</"    => '<\/',
      "\r\n"  => '\n',
      "\n"    => '\n',
      "\r"    => '\n',
      '"'     => '\\"',
      "'"     => "\\'",
      "`"     => "\\`",
      "$"     => "\\$"
    }.freeze

    def initialize(**kwargs)
      @js = MiniRacer::Context.new(kwargs)
      @js.load(Handlebars::Source.bundled_path)
    end

    # Note that this is a hacky JS expression builder. We cannot pass JS AST in to mini_racer so we have to
    # hope the template passed in does not form invalid Ruby. So don't use templates with backtick characters without
    # manually escaping them
    def compile(template)
      handle = fn_handle
      invocation = %{var #{handle} = Handlebars.compile("#{escape_javascript(template)}");}
      @js.eval(invocation)
      ::Smolbars::Template.new(self, handle)
    end

    def eval(*args)
      @js.eval(*args)
    end

    def load_pattern(pattern)
      Dir[pattern].each { |path| load(path) }
    end

    def load(path)
      @js.load(path)
    end

    private

    def fn_handle
      "js_fn_#{SecureRandom.hex}"
    end

    def escape_javascript(javascript)
      javascript = javascript.to_s
      if javascript.empty?
        ''
      else
        javascript.gsub(/(\\|<\/|\r\n|\342\200\250|\342\200\251|[\n\r"']|[`]|[$])/u, JS_ESCAPE_MAP)
      end
    end
  end
end
