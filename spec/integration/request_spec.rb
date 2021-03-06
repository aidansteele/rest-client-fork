require File.join( File.dirname(File.expand_path(__FILE__)), '../base')

describe RestClient::Request do
  shared_examples 'an http client' do
    describe "ssl verification" do
      it "is successful with the correct ca_file" do
        request = RestClient::Request.new(
          :method => :get,
          :url => 'https://www.mozilla.com',
          :verify_ssl => OpenSSL::SSL::VERIFY_PEER,
          :ssl_ca_file => File.join(File.dirname(__FILE__), "certs", "equifax.crt")
        )
        expect { request.execute }.to_not raise_error
      end

      # I don' think this feature is useful anymore (under 1.9.3 at the very least).
      #
      # Exceptions in verify_callback are ignored; RestClient has to catch OpenSSL::SSL::SSLError
      # and either re-throw it as is, or throw SSLCertificateNotVerified
      # based on the contents of the message field of the original exception
      #.
      # The client has to handle OpenSSL::SSL::SSLError exceptions anyway,
      # why make them handle both OpenSSL *AND* RestClient exceptions???
      #
      # also see https://github.com/ruby/ruby/blob/trunk/ext/openssl/ossl.c#L237
      it "is unsuccessful with an incorrect ca_file" do
        request = RestClient::Request.new(
          :method => :get,
          :url => 'https://www.mozilla.com',
          :verify_ssl => OpenSSL::SSL::VERIFY_PEER,
          :ssl_ca_file => File.join(File.dirname(__FILE__), "certs", "verisign.crt"),
          :cert_store => OpenSSL::X509::Store.new
        )
        expect { request.execute }.to raise_error(RestClient::SSLCertificateNotVerified)
      end
    end
  end

  describe 'with keep alive' do
    before :each do
      @previous_persistent = RestClient.persistent
      RestClient.persistent = true
    end

    after :each do
      RestClient.persistent = @previous_persistent
    end

    it_should_behave_like 'an http client'
  end

  describe 'without keep alive' do
    before :each do
      @previous_persistent = RestClient.persistent
      RestClient.persistent = false
    end

    after :each do
      RestClient.persistent = @previous_persistent
    end

    it_should_behave_like 'an http client'
  end

end
