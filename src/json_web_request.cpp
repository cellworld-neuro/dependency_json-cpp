#include <iostream>
#include <string>
#include <json_cpp/json_web_request.h>
#include <cstring>
#include <unistd.h>

using namespace std;
namespace json_cpp {
    Json_URI::Json_URI(const std::string &url) {
        stringstream ss (url);
        string part;
        getline(ss, part, ':');
        if ( part == "https") protocol = https;
        else if ( part == "http") protocol = http;
        else throw logic_error("supported protocols are http and https");
        getline(ss, part, '/');
        if (!part.empty()) throw logic_error("url format error");
        getline(ss, part, '/');
        if (!part.empty()) throw logic_error("url format error");
        getline(ss, part, '/');
        if (part.empty()) throw logic_error("url format error");
        if (part.find(':') !=std::string::npos){
            stringstream sd (part);
            getline(sd, domain, ':');
            string port_s;
            getline(sd, port_s, '/');
            port = stoi(port_s);
        } else {
            domain = part;
            port = protocol == http?80:443;
        }
        getline(ss, query_string);
    }

    Json_URI::Json_URI() {
        protocol = https;
        port = 443;
    }

    std::string Json_URI::url() const {
        stringstream ss;
        if (protocol == http) ss << "http";
        else ss <<"https";
        ss << "://" << domain << ":" << port << "/" << query_string;
        return ss.str();
    }

    std::ostream &operator<<(ostream &o, const Json_URI &uri) {
        o << uri.url();
        return o;
    }

    std::string gen_random(const int len) {
        static const char alphanum[] =
                "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                "abcdefghijklmnopqrstuvwxyz";
        std::string tmp_s;
        tmp_s.reserve(len);

        for (int i = 0; i < len; ++i) {
            tmp_s += alphanum[rand() % (sizeof(alphanum) - 1)];
        }

        return tmp_s;
    }

    Json_web_response Json_web_request::get_response() {
        auto url = uri.url();
        CURL *curl;
        FILE *fp;
        CURLcode res;
        curl = curl_easy_init();
        if (curl)
        {
            auto outfilename = "json_" + gen_random(10);
            fp = fopen(outfilename.c_str(),"wb");
            curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, NULL);
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
            res = curl_easy_perform(curl);
            curl_easy_cleanup(curl);
            fclose(fp);
            if (res == CURLE_OK) {
                return Json_web_response(outfilename, url);
            } else {
                throw logic_error("failed to download content from " + url);
            }
        } else {
            throw logic_error("failed to create curl object");
        }
    }

    Json_web_request::Json_web_request(Json_URI uri) : uri(uri) {}
}