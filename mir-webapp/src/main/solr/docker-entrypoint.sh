#!/usr/bin/bash
#
# This file is part of ***  M y C o R e  ***
# See http://www.mycore.de/ for details.
#
# MyCoRe is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# MyCoRe is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
#

set -e
unset SOLR_USER SOLR_UID SOLR_GROUP SOLR_GID \
      SOLR_CLOSER_URL SOLR_DIST_URL SOLR_ARCHIVE_URL SOLR_DOWNLOAD_URL SOLR_DOWNLOAD_SERVER SOLR_KEYS SOLR_SHA512

function fixDirectoryRights() {
  find "$1" \! -user "$2" -exec chown "$2:$2" '{}' +
}

echo "Running solr entry script as user: $(whoami)"
if [ "$(id -u)" -eq 0 ]; then
  fixDirectoryRights /var/solr/ solr
  exec /usr/bin/sudo -E -u solr "PATH=$PATH" "$(pwd)/$0";
  exit 0;
fi

function solrpass() {
  printf "%s %s" "$(echo -n "$2$1"|openssl dgst -sha256 -binary|openssl dgst -sha256 -binary|openssl base64)" "$(echo -n "$2"|openssl base64)"
}

secruity_json=/var/solr/data/security.json;


echo "{" > $secruity_json
echo "  \"authentication\":{" >> $secruity_json
echo "    \"blockUnknown\": true," >> $secruity_json
echo "    \"class\":\"solr.BasicAuthPlugin\"," >> $secruity_json
echo "    \"credentials\": {" >> $secruity_json

if [ -n "$SOLR_SEARCH_USER" ]; then
  echo "      \"${SOLR_SEARCH_USER}\":\"$(solrpass $SOLR_SEARCH_PASSWORD $(openssl rand 10))\"," >> $secruity_json
fi

if [ -n "$SOLR_INDEX_USER" ]; then
  echo "      \"${SOLR_INDEX_USER}\":\"$(solrpass $SOLR_INDEX_PASSWORD $(openssl rand 10))\"," >> $secruity_json
fi

if [ -n "$SOLR_ADMIN_USER" ]; then
  echo "      \"${SOLR_ADMIN_USER}\":\"$(solrpass $SOLR_ADMIN_PASSWORD $(openssl rand 10))\"" >> $secruity_json
fi

echo "    }," >> $secruity_json
echo "    \"realm\":\"My Solr users\"," >> $secruity_json
echo "    \"forwardCredentials\": false" >> $secruity_json
echo "  }," >> $secruity_json
echo "  \"authorization\":{" >> $secruity_json
echo "    \"class\":\"solr.RuleBasedAuthorizationPlugin\"," >> $secruity_json
echo "    \"permissions\":[" >> $secruity_json

if [ -n "$SOLR_SEARCH_USER" ]; then
  echo "      {" >> $secruity_json
  echo "        \"name\":\"read\"," >> $secruity_json
  echo "        \"role\":\"searcher\"" >> $secruity_json
  echo "      }," >> $secruity_json
fi

if [ -n "$SOLR_INDEX_USER" ]; then
  echo "      {" >> $secruity_json
  echo "        \"name\":\"update\"," >> $secruity_json
  echo "        \"role\":\"indexer\"" >> $secruity_json
  echo "      }," >> $secruity_json
fi

if [ -n "$SOLR_ADMIN_USER" ]; then
  echo "      {" >> $secruity_json
  echo "        \"name\":\"all\"," >> $secruity_json
  echo "        \"role\":\"admin\"" >> $secruity_json
  echo "      }" >> $secruity_json
fi
echo "]," >> $secruity_json
echo "    \"user-role\":{" >> $secruity_json

if [ -n "$SOLR_SEARCH_USER" ]; then
  echo "      \"${SOLR_SEARCH_USER}\":\"searcher\"," >> $secruity_json
fi

if [ -n "$SOLR_INDEX_USER" ]; then
  echo "      \"${SOLR_INDEX_USER}\":\"indexer\"," >> $secruity_json
fi

if [ -n "$SOLR_ADMIN_USER" ]; then
  echo "      \"${SOLR_ADMIN_USER}\":\"admin\"" >> $secruity_json
fi

echo "    }" >> $secruity_json
echo "  }" >> $secruity_json
echo "}" >> $secruity_json

(/opt/docker-solr/scripts/wait-for-solr.sh;/opt/solr/bin/solr zk cp $secruity_json zk:security.json -z localhost:9983)&
/opt/docker-solr/scripts/solr-foreground -c;