module Announcements
  class Admin::ApplicationController < Announcements::ApplicationController
    before_filter :authorize_admins, :journal_user

    def authorize_admins
      authorize! :access, :admin
    end

    def journal_user
      logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
    end
  end
end
