namespace :aws do
  task :bucket do
    $bucket = ENV["AWS_S3_BUCKET"]
    raise "AWS_S3_BUCKET is not set" unless $bucket
  end

  namespace :s3 do
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
end
