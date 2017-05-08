require_relative '../spec_helper'

describe Validator::TestsuiteFormatter do

  subject {
    Validator::TestsuiteFormatter.new output
  }

  let(:output) {
    output = StringIO.new
  }

  describe '#example_started' do
    let(:notification) {
      instance_double(RSpec::Core::Notifications::ExampleNotification)
    }

    let(:example) { double('example', description: 'example_name') }

    it 'prints the identation and example name' do
      allow(notification).to receive(:example).and_return(example)
      allow(subject).to receive(:current_indentation).and_return('IDENTATION')

      subject.example_started(notification)

      expect(output.string).to eq('IDENTATIONexample_name... ')
    end
  end

  describe '#example_passed' do
    it 'it prints `passed` in success color' do
      allow(RSpec::Core::Formatters::ConsoleCodes).to receive(:wrap).and_call_original

      subject.example_passed(nil)

      expect(RSpec::Core::Formatters::ConsoleCodes).to have_received(:wrap).with(anything, :success)
      expect(output.string).to eq("passed\n")
    end
  end

  describe '#example_failed' do
    it 'it prints `failed` in failure color' do
      allow(RSpec::Core::Formatters::ConsoleCodes).to receive(:wrap).and_call_original

      subject.example_failed(nil)

      expect(RSpec::Core::Formatters::ConsoleCodes).to have_received(:wrap).with(anything, :failure)
      expect(output.string).to eq("failed\n")
    end
  end

  describe '#example_pending' do

    let(:notification) {
      execution_result = double('execution_result', pending_message: 'pending_message')
      example = double('example', execution_result: execution_result)
      instance_double(RSpec::Core::Notifications::FailedExampleNotification, example:example)
    }

    it 'it prints the skipping reason in pending color' do
      allow(RSpec::Core::Formatters::ConsoleCodes).to receive(:wrap).and_call_original

      subject.example_pending(notification)

      expect(RSpec::Core::Formatters::ConsoleCodes).to have_received(:wrap).with(anything, :pending)
      expect(output.string).to eq("skipped: pending_message\n")
    end
  end

  describe '#dump_failures' do

    let(:notification) {
      instance_double(RSpec::Core::Notifications::ExamplesNotification)
    }

    let(:verbose) { false }

    before do
      allow(RSpec::configuration).to receive(:options).and_return(double('options', verbose?: verbose))
    end

    context 'when no failure occurred' do
      it 'should not print anything' do
        allow(notification).to receive(:failure_notifications).and_return([])

        subject.dump_failures(notification)

        expect(output.string).to be_empty
      end
    end

    context 'when there is a failure' do
      let(:failure_notification) { mock_failure_notification('Failure description', 'Failure exception') }

      it 'should report only the error number, error description and the error message' do
        allow(notification).to receive(:failure_notifications).and_return([failure_notification])

        subject.dump_failures(notification)

        expect(output.string).to eq("\nFailures:\n"\
                                    "\n" \
                                    "  1) Failure description\n" \
                                    "     Failure exception\n"
                                 )
      end

      context 'and VERBOSE_FORMATTER is used' do
        let(:verbose) { true }

        let(:failure_notification) { instance_double(RSpec::Core::Notifications::FailedExampleNotification) }

        it 'should report full stacktrace' do
          expect(failure_notification).to receive(:fully_formatted).and_return('some backtrace')
          allow(notification).to receive(:failure_notifications).and_return([failure_notification])

          subject.dump_failures(notification)

          expect(output.string).to eq("\nFailures:\n"\
                                    "some backtrace\n"
                                   )
        end
      end
    end

    context 'when there are multiple failures' do
      let(:failure_notification1) { mock_failure_notification('Failure description1', 'Failure exception1') }
      let(:failure_notification2) { mock_failure_notification('Failure description2', 'Failure exception2') }

      let(:verbose) { false }

      it 'should report only the error number, error description and the error message' do
        allow(notification).to receive(:failure_notifications).and_return([failure_notification1, failure_notification2])

        subject.dump_failures(notification)

        expect(output.string).to eq("\nFailures:\n" \
                                    "\n" \
                                    "  1) Failure description1\n" \
                                    "     Failure exception1\n" \
                                    "\n" \
                                    "  2) Failure description2\n" \
                                    "     Failure exception2\n"
                                 )
      end

      context 'and VERBOSE_FORMATTER is used' do
        let(:verbose) { true }

        let(:failure_notification1) { instance_double(RSpec::Core::Notifications::FailedExampleNotification) }
        let(:failure_notification2) { instance_double(RSpec::Core::Notifications::FailedExampleNotification) }

        it 'should report full stacktrace' do
          expect(failure_notification1).to receive(:fully_formatted).and_return("some backtrace\n")
          expect(failure_notification2).to receive(:fully_formatted).and_return("some other backtrace\n")
          allow(notification).to receive(:failure_notifications).and_return([failure_notification1, failure_notification2])

          subject.dump_failures(notification)

          expect(output.string).to eq("\nFailures:\n"\
                                    "some backtrace\n"\
                                    "some other backtrace\n"
                                   )
        end
      end
    end

    def mock_failure_notification(description, exception_message)
      failure_notification = instance_double(RSpec::Core::Notifications::FailedExampleNotification)
      allow(failure_notification).to receive(:description).and_return(description)
      allow(failure_notification).to receive(:exception).and_return(Exception.new(exception_message))
      failure_notification
    end
  end

  describe '#dump_pending' do
    it 'should not produce output' do
      # Allow exactly ***no*** interaction with the notification object
      notification = instance_double(RSpec::Core::Notifications::ExamplesNotification)

      subject.dump_pending(notification)

      expect(output.string).to be_empty
    end
  end

  describe '#dump_summary' do

    let(:failure_count) { 0 }
    let(:summary) { instance_double(RSpec::Core::Notifications::SummaryNotification) }
    let(:resources) { instance_double(Validator::Resources) }

    before(:each) do
      allow_any_instance_of(RSpec::Core::Configuration).to receive(:validator_resources).and_return(resources)

      allow(resources).to receive(:summary).and_return('resources-summary')
      allow(summary).to receive(:formatted_duration).and_return('47.11')
      allow(summary).to receive(:formatted_load_time).and_return('11.47')
      allow(summary).to receive(:failure_count).and_return(failure_count)
      allow(summary).to receive(:colorized_totals_line).and_return('3 examples, 1 failures, 1 pending')
    end

    it 'should report successful, pending and failing messages' do
      subject.dump_summary(summary)

      expect(output.string).to include("\nFinished in 47.11 (files took 11.47 to load)\n3 examples, 1 failures, 1 pending\n")
    end

    it 'gets the summary from the resource tracker' do
      subject.dump_summary(summary)

      expect(output.string).to include('resources-summary')
    end

    context 'with test failures' do

      let(:failure_count) { 1 }

      before(:each) do
        allow(RSpec::configuration).to receive(:options).and_return(double('options', log_path: 'test/path'))
      end

      it 'points the user to the log file' do
        subject.dump_summary(summary)

        expect(output.string).to match(/You can find more information in the logs at test\/path\/testsuite.log/)
      end
    end
  end
end