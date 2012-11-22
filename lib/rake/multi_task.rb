module Rake

  # Same as a regular task, but the immediate prerequisites are done in
  # parallel using Ruby threads.
  #
  class MultiTask < Task
    protected
    def invoke_prereqs_concurrently? # :nodoc:
      true
    end
  end

end
