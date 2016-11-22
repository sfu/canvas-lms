# module SFU
#   module Help
#     class Railtie < ::Rails::Railtie
#       initializer "sfu_help.prepend_module" do |app|
#         Account::HelpLinks.singleton_class.prepend(SFU::Help)
#       end
#     end
#     def default_links
#       []
#     end
#     def self.prepended(klass)
#       Rails.logger.info("****** prepended #{self} to #{klass}") unless Rails.env.production?
#     end
#   end
# end
