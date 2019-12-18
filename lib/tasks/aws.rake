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
    task client: [:bucket] do
      $client = Aws::TranscribeService::Client.new
      $client.extend Thor::Shell
      def $client.list
        Enumerator.new do |y|
          client = Aws::TranscribeService::Client.new
          res = nil
          while res.nil? || res.next_token.present?
            res =
              client.list_transcription_jobs(
                status: "COMPLETED",
                job_name_contains: $bucket,
                next_token: res&.next_token
              )
            res.transcription_job_summaries.each do |job|
              y << job
            end
          end
        end
      end
    end

    task jobs: [:client] do
      puts $client.list.map(&:to_h).to_json
    end

    namespace :jobs do
      task purge: [:client] do
        $client.list.each do |job|
          $client.delete_transcription_job(
            transcription_job_name: job.transcription_job_name
          )
          say_status :delete, job.transcription_job_name, :red
        end
      end
    end
  end
end
