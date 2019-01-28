module Embulk
  module Input

    class Example < InputPlugin
      Plugin.register_input("example", self)

      def self.transaction(config, &control)
        inputs = config[:inputs]
        task = {
          inputs: inputs,
          count: config.param(:count, :integer, default: 1)
        }

        columns = []
        config[:columns].each_with_index do |c, i|
          columns << Column.new(i, c['name'], c['type'].to_sym)
        end

        threads = 1

        resume(task, columns, threads, &control)
      end

      def self.resume(task, columns, count, &control)
        task_reports = yield(task, columns, count)

        next_config_diff = {}
        return next_config_diff
      end

      # TODO
      # def self.guess(config)
      #   sample_records = [
      #     {"example"=>"a", "column"=>1, "value"=>0.1},
      #     {"example"=>"a", "column"=>2, "value"=>0.2},
      #   ]
      #   columns = Guess::SchemaGuess.from_hash_records(sample_records)
      #   return {"columns" => columns}
      # end

      def run
        inputs = @task[:inputs]
        count = @task[:count]
        count.times do |i|
          inputs.each do |input|
            @page_builder.add(input)
          end
        end
        @page_builder.finish
      end
    end
  end
end
