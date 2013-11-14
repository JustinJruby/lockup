module Lockup
  class LockupController < Lockup::ApplicationController
    skip_before_filter :check_for_lockup
    
    def unlock
        puts 'params' + params.inspect
      if params[:lockup_codeword].present?
        user_agent = request.env['HTTP_USER_AGENT'].downcase
        unless user_agent.match(/crawl|googlebot|slurp|spider|bingbot|tracker|click|parser|spider/)
          @codeword = params[:lockup_codeword].to_s.downcase
          @return_to = params[:return_to]
          if @codeword == ENV["LOCKUP_CODEWORD"].to_s.downcase
            puts 'Have Code word in GET'
            set_cookie
            run_redirect
          end
        else
          puts 'Do Not have codeword'
          render :nothing => true
        end
      end

      if request.post?
        @codeword = params[:lockup][:codeword].to_s.downcase
        @return_to = params[:lockup][:return_to]
        if @codeword == ENV["LOCKUP_CODEWORD"].to_s.downcase
          puts 'codeword submit'
          set_cookie
          run_redirect
        else
          puts 'bad codeword'
          @wrong = true
        end
      end
    end
    
    private
    
    def set_cookie
      cookies[:lockup] = { :value => @codeword.to_s.downcase, :expires => (Time.now + 5.years) }
            puts 'set cookie to  ' + cookies[:lockup][:value]
    end
    
    def run_redirect
      if @return_to.present?
        puts 'redirect to return to'
        redirect_to "#{@return_to}"
      else
        puts 'redirect to /'+ "#{root_path}"
        redirect_to root_path
      end
    end

  end
end
