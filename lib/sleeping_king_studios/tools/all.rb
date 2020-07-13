# frozen_string_literal: true

require 'sleeping_king_studios/tools'

SleepingKingStudios::Tools::CoreTools
  .deprecate('sleeping_king_studios/tools/all')

Dir[File.join File.dirname(__FILE__), '*_tools.rb'].sort.each do |file|
  require file
end
