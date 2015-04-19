require "serverkit/resources/base"

module Serverkit
  module Resources
    class Directory < Base
      attribute :group, type: String
      attribute :mode, type: [Integer, String]
      attribute :owner, type: String
      attribute :path, required: true, type: String

      # @note Override
      def apply
        create_directory unless has_correct_directory?
        update_group unless has_correct_group?
        update_mode unless has_correct_mode?
        update_owner unless has_correct_owner?
      end

      # @note Override
      def check
        has_correct_directory? && has_correct_group? && has_correct_mode? && has_correct_owner?
      end

      private

      def create_directory
        run_command_from_identifier(:create_file_as_directory, path)
      end

      def has_correct_directory?
        check_command_from_identifier(:check_file_is_directory, path)
      end

      def has_correct_group?
        group.nil? || check_command_from_identifier(:check_file_is_grouped, path, group)
      end

      def has_correct_mode?
        mode.nil? || check_command_from_identifier(:check_file_has_mode, path, mode_in_octal_notation)
      end

      def has_correct_owner?
        owner.nil? || check_command_from_identifier(:check_file_is_owned_by, path, owner)
      end

      # @return [String]
      # @example "755" # for 0755
      def mode_in_octal_notation
        if mode.is_a?(Integer)
          mode.to_s(8)
        else
          mode
        end
      end

      def update_group
        run_command_from_identifier(:change_file_group, path, group)
      end

      def update_mode
        run_command_from_identifier(:change_file_mode, path, mode_in_octal_notation)
      end

      def update_owner
        run_command_from_identifier(:change_file_owner, path, owner)
      end
    end
  end
end