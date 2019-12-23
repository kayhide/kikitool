require "thor/shell"

extend Thor::Shell

namespace :aws do
  task :bucket do
    $bucket = ENV["AWS_S3_BUCKET"]
    raise "AWS_S3_BUCKET is not set" unless $bucket
  end

  namespace :s3 do
    task create: [:bucket] do
      sh "aws s3 mb s3://#{$bucket}"
    end

    task cors: [:bucket] do
      sh "aws s3api get-bucket-cors --bucket #{$bucket}"
    end

    namespace :cors do
      task put: [:bucket] do
        json = File.join(__dir__, "cors.json")
        sh "aws s3api put-bucket-cors --bucket #{$bucket} --cors-configuration file://#{json}"
      end
    end
  end

  namespace :transcribe do
    task :client do
      $client = Aws::TranscribeService::Client.new
      $client.extend Thor::Shell
      def $client.list method, args = {}
        Enumerator.new do |y|
          res = nil
          while res.nil? || res.next_token.present?
            res = $client.send("list_#{method}", args.merge(next_token: res&.next_token))
            items = res.values.find { |x| x.is_a? Array }
            items.each do |item|
              y << item
            end
          end
        end
      end

      def $client.scope
        @scope ||= ENV["AWS_S3_BUCKET"]
        raise "AWS_S3_BUCKET is not set" unless @scope
        @scope
      end
    end

    task jobs: [:client] do
      puts $client.list(
        :transcription_jobs,
        status: "COMPLETED",
        job_name_contains: $client.scope
      ).map(&:to_h).to_json
    end

    namespace :jobs do
      task purge: [:client] do
        $client.list(
          :transcription_jobs,
          status: "COMPLETED",
          job_name_contains: $client.scope
        ).each do |item|
          $client.delete_transcription_job(
            item.to_h.slice(:transcription_job_name)
          )
          say_status :delete, item.transcription_job_name, :red
        end
      end
    end

    task vocabulary_filters: [:client] do
      puts $client.list(
        :vocabulary_filters,
        name_contains: $client.scope
      ).map(&:to_h).to_json
    end

    namespace :vocabulary_filters do
      task purge: [:client] do
        $client.list(
          :vocabulary_filters,
          name_contains: $client.scope
        ).each do |item|
          $client.delete_vocabulary_filter(
            item.to_h.slice(:vocabulary_filter_name)
          )
          say_status :delete, item.vocabulary_filter_name, :red
        end
      end
    end

  end
end
