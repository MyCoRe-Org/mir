<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:str="http://exslt.org/strings"
  xmlns:exslt="http://exslt.org/common"
  xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:basket="xalan://org.mycore.frontend.basket.MCRBasketManager"
  xmlns:decoder="xalan://java.net.URLDecoder"
  exclude-result-prefixes="i18n mods str exslt mcr acl mcrxsl basket encoder decoder">

  <xsl:import href="xslImport:badges" />
  <xsl:import href="resource:xsl/orcid/mir-orcid-user.xsl"/>
  <xsl:include href="resource:xsl/orcid/mir-orcid-export-ui.xsl"/>
  <xsl:include href="resource:xsl/orcid/mir-orcid-work.xsl"/>
  <xsl:include href="resource:xsl/csl-export-gui.xsl" />
  <xsl:include href="resource:xsl/response-facets.xsl"/>
  <xsl:include href="resource:xsl/response-mir-utils.xsl" />

  <xsl:param name="UserAgent" />
  <xsl:param name="MIR.testEnvironment" />
  <xsl:param name="MIR.Solr.Secondary.Search.RequestHandler.List" select="'find'" />
  <xsl:param name="RequestURL" />

  <xsl:variable name="maxScore" select="//result[@name='response'][1]/@maxScore" />

  <xsl:template match="/response/result|lst[@name='grouped']/lst[@name='returnId']" priority="10">
    <xsl:variable name="ResultPages">
      <xsl:if test="($hits &gt; 0) and ($hits &gt; $rows)">
        <div class="pagination_box text-center">
          <xsl:call-template name="resultList.Pagination">
            <xsl:with-param name="id" select="'solr-result'" />
            <xsl:with-param name="numPerPage" select="$rows" />
            <xsl:with-param name="page" select="$currentPage" />
            <xsl:with-param name="pages" select="$totalPages" />
            <xsl:with-param name="class" select="'pagination-sm'" />
          </xsl:call-template>
        </div>
      </xsl:if>
    </xsl:variable>

    <div class="row result_head">
      <div class="col-12 result_headline">
        <h1>
          <xsl:choose>
            <xsl:when test="$hits=0">
              <xsl:value-of select="i18n:translate('results.noObject')" />
            </xsl:when>
            <xsl:when test="$hits=1">
              <xsl:value-of select="i18n:translate('results.oneObject')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="i18n:translate('results.nObjects',$hits)" />
            </xsl:otherwise>
          </xsl:choose>
        </h1>
      </div>
    </div>

<!-- Suchschlitz mit Suchbegriff, Treffer - Nummer, Vorschau, Autor, Änderungsdatum, Link zu den Details, Filter  -->
    <div class="row result_searchline">
      <div class="col-12 col-sm-8 text-center result_search">

        <!-- check which SOLR RequestHandler is used, if the value is from the list of the -->
        <!-- $MIR.Solr.Secondary.Search.RequestHandler.List, then it shows the form with secondary search -->
        <xsl:variable name="isSolrSearchRequest">
          <xsl:for-each select="str:tokenize($MIR.Solr.Secondary.Search.RequestHandler.List, ',')">
            <xsl:variable name="handlerPattern" select="concat('/servlets/solr/', .)"/>
            <xsl:if test="contains($RequestURL, $handlerPattern)">
              <xsl:variable name="afterHandler" select="substring-after($RequestURL, $handlerPattern)"/>
              <xsl:if test="
                $afterHandler = '' or
                starts-with($afterHandler, '?') or
                starts-with($afterHandler, '&amp;')">
                <xsl:text>true</xsl:text>
              </xsl:if>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>

        <xsl:if test="normalize-space($isSolrSearchRequest) = 'true'">

          <div class="search_box">

            <!-- Check if 'condQuery' exists and extract its value if it does -->
            <xsl:variable name="condQuery" select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='condQuery']" />

            <!-- Check if 'initialCondQuery' exists and extract its value if it does -->
            <xsl:variable name="initialCondQuery" select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='initialCondQuery']" />

            <!-- Check if 'fq' exists and extract its value if it does -->
            <xsl:variable name="fq">
              <xsl:choose>
                <!-- Case 1: fq is an array -->
                <xsl:when test="/response/lst[@name='responseHeader']/lst[@name='params']/arr[@name='fq']">
                  <xsl:value-of select="/response/lst[@name='responseHeader']/lst[@name='params']/arr[@name='fq']/str[
                starts-with(., 'mods.title:') or
                starts-with(., 'mods.author:') or
                starts-with(., 'mods.name.top:') or
                starts-with(., 'mods.nameIdentifier:') or
                starts-with(., 'allMeta:')
            ][1]" />
                </xsl:when>

                <!-- Case 2: fq is a single string -->
                <xsl:when test="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='fq']">
                  <xsl:if test="starts-with(/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='fq'], 'mods.title:') or
                          starts-with(/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='fq'], 'mods.author:') or
                          starts-with(/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='fq'], 'mods.name.top:') or
                          starts-with(/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='fq'], 'mods.nameIdentifier:') or
                          starts-with(/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='fq'], 'allMeta:')">
                    <xsl:value-of select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='fq']" />
                  </xsl:if>
                </xsl:when>

                <!-- Default: No valid fq parameter found -->
                <xsl:otherwise>
                  <xsl:text />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <!-- Check if 'owner' exists and extract its value if it does -->
            <xsl:variable name="owner" select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='owner']" />

            <!-- Check if 'version' exists and extract its value if it does -->
            <xsl:variable name="version" select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='version']" />

            <!-- Extract part before ':' ('%3A') if $fq is not empty or null -->
            <xsl:variable name="initialSelectMods">
              <xsl:choose>
                <xsl:when test="$fq and normalize-space($fq) != ''">
                  <!-- xsl:value-of select="substring-before($fq, '%3A')" / -->
                  <xsl:value-of select="substring-before($fq, ':')" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="'all'" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <!-- Extract part after ':' ('%3A') if $fq is not empty or null -->
            <xsl:variable name="filterQueryValue">
              <xsl:choose>
                <xsl:when test="$fq">
                  <xsl:value-of select="substring-after($fq, ':')" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="''" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <!-- Variable for the 'action' attribute in the form element (without query parameters) -->
            <xsl:variable name="searchlink" select="$proxyBaseURL" />

            <!-- Form for the second search -->
            <form action="{$searchlink}" class="search_form" method="post">
              <xsl:choose>
                <xsl:when test="not($fq)">
                  <input type="hidden" id="fq" name="fq" value=""/>
                </xsl:when>
                <xsl:otherwise>
                  <input type="hidden" id="fq" name="fq" value="{$fq}"/>
                </xsl:otherwise>
              </xsl:choose>

              <!-- Hidden elements with request parameters -->
              <input type="hidden" id="initialCondQuerySecond" name="initialCondQuery" value="{$initialCondQuery}"/>
              <input type="hidden" id="owner" name="owner" value="{$owner}"/>
              <input type="hidden" id="version" name="version" value="{$version}"/>

              <div class="input-group">
                <!-- Dropdown for the filter query (select mods) -->
                <button type="button" class="btn btn-primary dropdown-toggle" data-bs-toggle="dropdown"
                        value="{$initialSelectMods}" id="select_mods">
                  <span id="select_mods_label">
                    <xsl:choose>
                      <xsl:when test="$initialSelectMods = 'mods.title'">
                        <xsl:value-of select="i18n:translate('mir.dropdown.title')"/>
                      </xsl:when>
                      <xsl:when test="$initialSelectMods = 'mods.author'">
                        <xsl:value-of select="i18n:translate('mir.dropdown.author')"/>
                      </xsl:when>
                      <xsl:when test="$initialSelectMods = 'mods.name.top'">
                        <xsl:value-of select="i18n:translate('mir.dropdown.name')"/>
                      </xsl:when>
                      <xsl:when test="$initialSelectMods = 'mods.nameIdentifier'">
                        <xsl:value-of select="i18n:translate('mir.dropdown.nameIdentifier')"/>
                      </xsl:when>
                      <xsl:when test="$initialSelectMods = 'allMeta'">
                        <xsl:value-of select="i18n:translate('mir.dropdown.allMeta')"/>
                      </xsl:when>
                      <xsl:when test="$initialSelectMods = 'content'">
                        <xsl:value-of select="i18n:translate('mir.dropdown.content')"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="i18n:translate('mir.dropdown.all')"/>
                      </xsl:otherwise>
                    </xsl:choose>

                  </span>
                  <span class="caret"></span>
                </button>
                <ul class="dropdown-menu select_mods_type">
                  <li>
                    <a href="#" value="all" class="dropdown-item">
                      <xsl:value-of select="i18n:translate('mir.dropdown.all')"/>
                    </a>
                  </li>
                  <li>
                    <a href="#" value="mods.title" class="dropdown-item">
                      <xsl:value-of select="i18n:translate('mir.dropdown.title')"/>
                    </a>
                  </li>
                  <li>
                    <a href="#" value="mods.author" class="dropdown-item">
                      <xsl:value-of select="i18n:translate('mir.dropdown.author')"/>
                    </a>
                  </li>
                  <li>
                    <a href="#" value="mods.name.top" class="dropdown-item">
                      <xsl:value-of select="i18n:translate('mir.dropdown.name')"/>
                    </a>
                  </li>
                  <li>
                    <a href="#" value="mods.nameIdentifier" class="dropdown-item">
                      <xsl:value-of select="i18n:translate('mir.dropdown.nameIdentifier')"/>
                    </a>
                  </li>
                  <li>
                    <a href="#" value="allMeta" class="dropdown-item">
                      <xsl:value-of select="i18n:translate('mir.dropdown.allMeta')"/>
                    </a>
                  </li>
                  <li>
                    <a href="#" value="content" class="dropdown-item">
                      <xsl:value-of select="i18n:translate('mir.dropdown.content')"/>
                    </a>
                  </li>
                </ul>

                <xsl:variable name="resolver">
                  <xsl:call-template name="substring-after-last">
                    <xsl:with-param name="string" select="$proxyBaseURL" />
                    <xsl:with-param name="delimiter" select="'/'" />
                  </xsl:call-template>
                </xsl:variable>

                <xsl:variable name="query">
                  <xsl:choose>
                    <xsl:when test="$condQuery">
                      <xsl:choose>
                        <xsl:when test="$condQuery = $initialCondQuery">
                          <xsl:value-of select="''" />
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:variable name="searchString" select="concat($initialCondQuery, ' AND ')" />
                          <xsl:value-of select="substring-after($condQuery, $searchString)" />
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="''" />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>

                <!-- Get a current qry from the last request value -->
                <xsl:variable name="currentQryFromLastRequest">
                  <xsl:choose>
                    <xsl:when test="not($filterQueryValue) or $filterQueryValue = ''">
                      <xsl:value-of select="$query" />
                    </xsl:when>
                    <xsl:when test="$filterQueryValue = '*'">
                      <!-- If filterQueryValue is '*', leave value empty -->
                      <xsl:value-of select="''" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$filterQueryValue" />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>

                <!-- Decode the current query -->
                <xsl:variable name="decodedCurrentQryFromLastRequest"
                              select="decoder:decode($currentQryFromLastRequest, 'UTF-8')" />

                <!-- Get a type of the last request -->
                <xsl:variable name="lastTypeRequest">
                  <xsl:choose>
                    <xsl:when test="not($filterQueryValue) or $filterQueryValue = ''">
                      <xsl:choose>
                        <xsl:when test="$condQuery = $initialCondQuery">
                          <xsl:value-of select="''" />
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="'condQuery'" />
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="'fq'" />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>

                <!-- Hidden query parameter 'condQuery' or 'q' based on $resolver -->
                <input type="hidden" id="condQuery">
                  <!-- Conditionally set the 'name' attribute based on the value of $resolver -->
                  <xsl:attribute name="name">
                    <xsl:choose>
                      <!-- If $resolver is 'find', use 'condQuery' -->
                      <xsl:when test="$resolver = 'find'">
                        <xsl:value-of select="'condQuery'" />
                      </xsl:when>
                      <!-- Otherwise, use 'q' -->
                      <xsl:otherwise>
                        <xsl:value-of select="'q'" />
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>

                  <!-- Set the 'value' attribute based on conditions -->
                  <xsl:attribute name="value">
                    <xsl:choose>
                      <!-- If $lastTypeRequest is 'condQuery' -->
                      <xsl:when test="$lastTypeRequest = 'condQuery'">
                        <xsl:choose>
                          <!-- If $initialCondQuery is '*' or empty -->
                          <xsl:when test="$initialCondQuery = '*' or $initialCondQuery = ''">
                            <xsl:value-of select="'*'" />
                          </xsl:when>
                          <!-- Otherwise, concatenate $initialCondQuery, ' AND ' and $decodedCurrentQryFromLastRequest -->
                          <xsl:otherwise>
                            <xsl:value-of select="concat($initialCondQuery, ' AND ', $decodedCurrentQryFromLastRequest)" />
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <!-- If $lastTypeRequest is 'fq' or empty, use $initialCondQuery -->
                      <xsl:when test="$lastTypeRequest = 'fq' or $lastTypeRequest = ''">
                        <xsl:value-of select="$initialCondQuery" />
                      </xsl:when>
                      <!-- Default case, use $initialCondQuery -->
                      <xsl:otherwise>
                        <xsl:value-of select="$initialCondQuery" />
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                </input>

                <!-- Preparing the current query for the input field (remove all quotes) -->
                <xsl:variable name="preparedCurrentQryFromLastRequest"
                              select="translate($decodedCurrentQryFromLastRequest, '&quot;', '')" />
                <!-- Input element for the second search -->
                <input aria-label="{i18n:translate('mir.placeholder.response.search')}" class="form-control" id="qry" placeholder="{i18n:translate('mir.placeholder.response.search')}"
                       type="text" value="{$preparedCurrentQryFromLastRequest}" />

                <button aria-label="Search button" class="btn btn-primary" type="submit">
                  <span class="fas fa-search"></span>
                  <xsl:value-of select="i18n:translate('editor.search.search')"/>
                </button>
              </div>
            </form>
          </div>

        </xsl:if>
      </div>

      <!-- START: alle zu basket -->
      <div class="col-12 col-sm-4">
        <form class="basket_form" action="{$ServletsBaseURL}MCRBasketServlet" method="post">
          <input type="hidden" name="action" value="add" />
          <input type="hidden" name="redirect" value="referer" />
          <input type="hidden" name="type" value="objects" />
          <xsl:variable name="idNodes" select="/response/result/doc|/response/lst[@name='grouped']/lst[@name='returnId']/arr[@name='groups']/lst/str[@name='groupValue']" />
          <xsl:for-each select="$idNodes">
            <xsl:variable name="docID">
              <xsl:choose>
                <xsl:when test="@id!=''">
                  <xsl:value-of select="@id" />
                </xsl:when>
                <xsl:when test="str[@name='id']">
                  <xsl:value-of select="str[@name='id']" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="." />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <input type="hidden" name="id" value="{$docID}" />
            <input type="hidden" name="uri" value="{concat('mcrobject:',$docID)}" />
          </xsl:for-each>
          <xsl:variable name="buttonDefaultClasses" select="'basket_button btn btn-primary form-control'" />
          <button type="submit" tabindex="1" aria-label="Plus Button" value="add">
            <xsl:choose>
              <xsl:when test="count($idNodes)=0">
                <xsl:attribute name="disabled">disabled</xsl:attribute>
                <xsl:attribute name="class"><xsl:value-of select="$buttonDefaultClasses" /> disabled</xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="class"><xsl:value-of select="$buttonDefaultClasses" /></xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
            <i class="fas fa-plus"></i>
            <xsl:text> </xsl:text>
            <xsl:value-of select="i18n:translate('basket.add.searchpage')" />
          </button>
        </form>
      </div>
      <!-- ENDE: alle zu basket -->

    </div> <!-- ENDE: Suchschlitz mit Suchbegriff -->

    <!-- xsl:if test="string-length(/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='q']) &gt; 0">
      <div class="row">
        <div class="col-12 col-sm-8">
          <span class="fas fa-remove-circle"></span>
          <xsl:value-of select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='q']" />
        </div>
      </div>
    </xsl:if -->

<!-- Filter, Pagination & Trefferliste -->
    <div class="row result_body">

      <div class="col-12 col-sm-8 result_list">
        <xsl:comment>
          RESULT LIST START
        </xsl:comment>
        <div id="hit_list">
          <xsl:apply-templates select="doc|arr[@name='groups']/lst/str[@name='groupValue']" />
        </div>
        <xsl:comment>
          RESULT LIST END
        </xsl:comment>
        <div class="result_list_end" />
        <xsl:copy-of select="$ResultPages" />
      </div>

      <div class="col-12 col-sm-4 result_filter">
        <div class="row result_export">
          <div class="col-12">
            <xsl:if test="$hits &gt; 0">
              <xsl:call-template name="exportGUI">
                <xsl:with-param name="type" select="'response'" />
              </xsl:call-template>
            </xsl:if>
          </div>
        </div>

        <!-- Dynamic facets -->
        <xsl:call-template name="facets" />

        <xsl:if test="$MIR.testEnvironment='true'"> <!-- filters in development, show only in test environments -->
          <xsl:call-template name="print.classiFilter">
            <xsl:with-param name="classId" select="'mir_institutes'" />
            <xsl:with-param name="i18nKey" select="'editor.search.mir.institute'" />
          </xsl:call-template>
          <xsl:call-template name="print.classiFilter">
            <xsl:with-param name="classId" select="'SDNB'" />
            <xsl:with-param name="i18nKey" select="'editor.search.mir.sdnb'" />
          </xsl:call-template>
          <xsl:call-template name="print.dateFilter" />
        </xsl:if>
      </div>

    </div>
    <xsl:if test="$isOrcidEnabled">
      <xsl:call-template name="render-export-to-orcid-modal"/>
      <script type="module" src="{$WebApplicationBaseURL}js/mir/orcid-result-list.js"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="doc" priority="10" mode="resultList">
    <xsl:param name="hitNumberOnPage" select="count(preceding-sibling::*[name()=name(.)])+1" />
    <!--
      Do not read MyCoRe object at this time
    -->
    <xsl:variable name="identifier">
      <xsl:choose>
        <xsl:when test="@id!=''">
          <xsl:value-of select="@id" />
        </xsl:when>
        <xsl:when test="str[@name='id']">
          <xsl:value-of select="str[@name='id']" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="mcrobj" select="." />
    <xsl:variable name="mods-genre">
      <xsl:choose>
        <xsl:when test="arr[@name='mods.genre']">
          <xsl:value-of select="arr[@name='mods.genre']/str" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'article'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="mods-genre-i18n" select="mcrxsl:getDisplayName('mir_genres',$mods-genre)" />
    <xsl:variable name="hitItemClass">
      <xsl:choose>
        <xsl:when test="$hitNumberOnPage mod 2 = 1">
          odd
        </xsl:when>
        <xsl:otherwise>
          even
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- generate browsing url -->
    <xsl:variable name="href" select="concat($proxyBaseURL,$solrParams)" />
    <xsl:variable name="startPosition" select="$hitNumberOnPage - 1 + (($currentPage) -1) * $rows" />
    <xsl:variable name="completeHref">
      <xsl:variable name="q">
        <xsl:call-template name="detectSearchParam">
          <xsl:with-param name="join" select="'&amp;passthrough.'"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="concat($href, '&amp;start=',$startPosition, '&amp;fl=id&amp;rows=1&amp;origrows=', $rows, '&amp;XSL.Style=browse', $q)"/>
    </xsl:variable>
    <xsl:variable name="hitHref">
      <xsl:value-of select="mcrxsl:regexp($completeHref, '&amp;XSL.Transformer=response-resultlist', '')"/>
    </xsl:variable>

    <!-- derivate variables -->
    <xsl:variable name="derivates" select="key('derivate', $identifier)"/>
    <!-- <xsl:variable name="derivid" select="$derivates/str[@name='derivateMaindoc'][1]/../str[@name='id']"/> -->
    <xsl:variable name="derivid">
      <xsl:choose>
        <xsl:when test="count($derivates[count(arr[@name='derivateType']/str[text() = 'content'])&gt;0 and count(str[@name='derivateMaindoc']) &gt; 0])&gt;0">
          <xsl:value-of select="$derivates[count(arr[@name='derivateType']/str[text() = 'content'])&gt;0 and count(str[@name='derivateMaindoc']) &gt; 0][1]/str[@name='id']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="derivate" select="$derivates[str[@name='id']=$derivid]"/>
    <xsl:variable name="maindoc" select="$derivates/str[@name='derivateMaindoc'][1]"/>
    <xsl:variable name="derivbase" select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derivid,'/')"/>
    <xsl:variable name="derivifs" select="concat($derivbase,$maindoc)"/>


    <xsl:variable name="hitCount" select="$hitNumberOnPage + (($currentPage) -1) * $rows"/>

    <!-- hit entry -->
    <div id="hit_{$hitCount}" class="hit_item {normalize-space($hitItemClass)}">

      <!-- hit head -->
      <div class="row hit_item_head">
        <div class="col-12">

          <!-- hit number -->
          <div class="hit_counter">
            <xsl:value-of select="$hitCount" />
          </div>

<!-- relevance -->
          <xsl:variable name="score" select="float[@name='score']" />
          <xsl:if test="$score &gt; 0 and $maxScore &gt; 0">
            <xsl:variable name="relevance" select="($score div $maxScore) * 100" />
            <div class="hit_stars_5 hit_stars" title="{i18n:translate('mir.response.relevance')}: {$relevance}%">
              <xsl:if test="$relevance &gt; 0">
                <div class="hit_star_1 hit_star"></div>
              </xsl:if>
              <xsl:if test="$relevance &gt; 20">
                <div class="hit_star_2 hit_star"></div>
              </xsl:if>
              <xsl:if test="$relevance &gt; 40">
                <div class="hit_star_3 hit_star"></div>
              </xsl:if>
              <xsl:if test="$relevance &gt; 60">
                <div class="hit_star_4 hit_star"></div>
              </xsl:if>
              <xsl:if test="$relevance &gt; 80">
                <div class="hit_star_5 hit_star"></div>
              </xsl:if>
            </div>
          </xsl:if>

<!-- hit options -->
          <xsl:choose>
            <xsl:when test="not($isGuestUser)">
              <div class="hit_options float-end">
                <div class="btn-group">
                  <a data-bs-toggle="dropdown" class="btn btn-secondary dropdown-toggle" href="#">
                    <i class="fas fa-cog"></i>
                    <xsl:value-of select="concat(' ',i18n:translate('mir.actions'))" />
                    <span class="caret"></span>
                  </a>
                  <ul class="dropdown-menu dropdown-menu-end">
                    <li>
                      <xsl:call-template name="basketLink">
                        <xsl:with-param name="identifier" select="$identifier" />
                        <xsl:with-param name="dropdown" select="'true'" />
                      </xsl:call-template>
                    </li>
                        <!-- direct link to editor -->
                    <xsl:if test="document(concat('checkPermission:', $identifier, ':writedb'))/boolean='true'">
                      <li>
                        <xsl:variable name="editURL">
                          <xsl:call-template name="mods.getObjectEditURL">
                            <xsl:with-param name="id" select="$identifier" />
                            <xsl:with-param name="layout" select="'$'" />
                          </xsl:call-template>
                        </xsl:variable>
                        <a class="hit_option hit_edit dropdown-item">
                          <xsl:choose>
                            <xsl:when test="string-length($editURL) &gt; 0">
                              <xsl:attribute name="href">
                                    <xsl:value-of select="$editURL" />
                                  </xsl:attribute>
                              <span class="fas fa-pencil-alt"></span>
                              <xsl:value-of select="i18n:translate('object.editObject')" />
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:attribute name="href">
                                    <xsl:value-of select="'#'" />
                                  </xsl:attribute>
                              <span class="fas fa-pencil-alt"></span>
                              <xsl:value-of select="i18n:translate('object.locked')" />
                            </xsl:otherwise>
                          </xsl:choose>
                        </a>
                      </li>
                    </xsl:if>
                    <xsl:if test="$isOrcidEnabled">
                      <li>
                        <xsl:variable name="currentUserHasTrustedMatchingId">
                          <xsl:call-template name="check-current-user-has-trusted-matching-id">
                            <xsl:with-param name="nameIds" select="arr[@name='mods.nameIdentifier']/str"/>
                          </xsl:call-template>
                        </xsl:variable>
                        <xsl:variable name="isPublishable">
                          <xsl:call-template name="check-state-is-publishable">
                            <xsl:with-param name="state" select="str[@name='state']"/>
                          </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="render-export-to-orcid-menu-item">
                          <xsl:with-param name="objectId" select="$identifier"/>
                          <xsl:with-param name="disabled"
                            select="$isPublishable='false' or $currentUserHasTrustedMatchingId='false' or not($hasLinkedOrcidCredential)"/>
                        </xsl:call-template>
                      </li>
                    </xsl:if>
                  </ul>
                </div>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <div class="single_hit_option float-end">
                <xsl:call-template name="basketLink">
                  <xsl:with-param name="identifier" select="$identifier" />
                  <xsl:with-param name="dropdown" select="'false'" />
                </xsl:call-template>
              </div>
            </xsl:otherwise>
          </xsl:choose>
          


        </div><!-- end col -->
      </div><!-- end row head -->


<!-- hit body -->
      <div class="row hit_item_body">
        <div class="col-12">

<!-- document preview -->
          <div class="hit_download_box">
            <xsl:variable name="viewerLink">
              <xsl:choose>
                <xsl:when test="string-length($derivid) = 0">
                  <!-- no link to no derivate -->
                </xsl:when>

                <xsl:when test="not(acl:checkDerivateDisplayPermission($derivid))">
                  <!-- no link if we can not read -->
                </xsl:when>

                <xsl:when test="$derivate/str[@name='iviewFile']">
                  <xsl:value-of select="concat($WebApplicationBaseURL, 'rsc/viewer/', $derivid,'/', $derivate/str[@name='iviewFile'])"/>
                </xsl:when>
                <xsl:when test="translate(str:tokenize($derivate/str[@name='derivateMaindoc'],'.')[position()=last()],'PDF','pdf') = 'pdf'">
                  <xsl:variable name="filePath" select="concat($derivate/str[@name='id'],'/',mcr:encodeURIPath($derivate/str[@name='derivateMaindoc']))"/>
                  <xsl:choose>
                    <xsl:when test="mcrxsl:isMobileDevice($UserAgent)">
                      <!-- for mobile users just show the file link -->
                      <xsl:value-of select="$derivifs"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <!-- only desktop users get the mycore-viewer -->
                      <xsl:variable name="q">
                        <xsl:call-template name="detectSearchParam"/>
                      </xsl:variable>
                      <xsl:value-of select="concat($WebApplicationBaseURL, 'rsc/viewer/', $filePath, $q)"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>

            <!-- choose which derivate is responsible for the thumbnail -->
            <xsl:variable name="displayDerivateID">
              <xsl:choose>
                <!-- first priority has the thumbnail derivate -->
                <xsl:when test="count($derivates[arr[@name='derivateType']/str/text() = 'thumbnail' and count(str[@name='derivateMaindoc']) &gt; 0])&gt;0">
                  <xsl:value-of select="$derivates[arr[@name='derivateType']/str/text() = 'thumbnail' and count(str[@name='derivateMaindoc']) &gt; 0][1]/str[@name='id']"/>
                </xsl:when>
                <!-- second priority has the first other derivate with a maindoc -->
                <xsl:when test="count($derivates[count(str[@name='derivateMaindoc']) &gt; 0])&gt;0">
                  <xsl:value-of select="$derivates[count(str[@name='derivateMaindoc']) &gt; 0][1]/str[@name='id']"/>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="displayDerivate" select="$derivates[str[@name='id'] = $displayDerivateID]"/>

            <!-- produces the thumbnail html-->
            <xsl:variable name="imageElement">
              <xsl:choose>
                <!-- when the thumbnail derivate has pdf as maindoc or a iviewFile, then use the iiif api -->
                <xsl:when
                        test="$displayDerivate/str[@name='iviewFile'] or translate(str:tokenize($displayDerivate/str[@name='derivateMaindoc'],'.')[position()=last()],'PDF','pdf') = 'pdf'">
                  <div class="hit_icon">
                    <xsl:choose>
                      <xsl:when test="not($isGuestUser)">
                        <xsl:attribute name="data-iiif-jwt">
                          <xsl:value-of select="concat($WebApplicationBaseURL, 'api/iiif/image/v2/thumbnail/', $identifier,'/full/!300,300/0/default.jpg')"/>
                        </xsl:attribute>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:attribute name="style">
                          <xsl:variable name="apos">'</xsl:variable>
                          <xsl:value-of
                                  select="concat('background-image: url(', $apos, $WebApplicationBaseURL, 'api/iiif/image/v2/thumbnail/', $identifier, '/full/!300,300/0/default.jpg',$apos,')')"/>
                        </xsl:attribute>
                      </xsl:otherwise>
                    </xsl:choose>
                  </div>
                </xsl:when>
                <!-- when there is no content derivate then use disabled icon -->
                <xsl:when test="string-length($derivid)=0">
                  <img class="hit_icon" src="{$WebApplicationBaseURL}images/icons/icon_common_disabled.png"/>
                </xsl:when>
                <xsl:otherwise>
                  <div class="hit_icon"
                       style="background-image: url('{$WebApplicationBaseURL}images/icons/icon_common.png');"/>
                  <!-- if not, then the content type decides a icon -->
                  <xsl:variable name="contentType"
                                select="document(concat('ifs:/',$derivid))/mcr_directory/children/child[name=$maindoc]/contentType"/>
                  <xsl:variable name="iconLink">
                    <xsl:call-template name="iconLink">
                      <xsl:with-param name="baseURL" select="$WebApplicationBaseURL"/>
                      <xsl:with-param name="mimeType" select="$contentType"/>
                      <xsl:with-param name="derivateMaindoc" select="$displayDerivate/str[@name='derivateMaindoc']"/>
                    </xsl:call-template>
                  </xsl:variable>
                  <img class="hit_icon_overlay" src="{$iconLink}"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <xsl:choose>
              <xsl:when test="string-length($viewerLink) &gt;0">
                <a class="hit_option hit_download" href="{$viewerLink}" title="{$mods-genre-i18n}">
                  <xsl:copy-of select="$imageElement"/>
                </a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="$imageElement"/>
              </xsl:otherwise>
            </xsl:choose>

          </div>

<!-- hit type -->
          <div class="hit_tnd_container">
            <div class="hit_tnd_content mir-badge-container">
              <xsl:apply-templates select="." mode="badge"/>
            </div>
          </div>

<!-- hit headline -->
          <h3 class="hit_title">
            <a href="{$hitHref}">
              <xsl:attribute name="title">
                    <xsl:value-of select="./str[@name='mods.title.main']" />
                    <xsl:if test="./str[@name='mods.title.subtitle']">
                      <xsl:value-of select="concat(' : ', ./str[@name='mods.title.subtitle'])" />
                    </xsl:if>
                  </xsl:attribute>
              <xsl:choose>
                <xsl:when test="./str[@name='search_result_link_text']">
                  <xsl:value-of select="./str[@name='search_result_link_text']" />
                </xsl:when>
                <xsl:when test="./str[@name='fileName']">
                  <xsl:value-of select="./str[@name='fileName']" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$identifier" />
                </xsl:otherwise>
              </xsl:choose>
            </a>
          </h3>

<!-- hit author -->
          <xsl:if
            test="arr[@name='mods.nameByRole.personal.aut'] or arr[@name='mods.nameByRole.personal.edt'] or arr[@name='mods.nameByRole.corporate.pbl'] or arr[@name='mods.nameByRole.corporate.edt']"
          >
            <div class="hit_author">
              <xsl:variable name="nameList">
                <xsl:choose>
                  <xsl:when test="arr[@name='mods.nameByRole.personal.aut']">
                    <xsl:copy-of select="arr[@name='mods.nameByRole.personal.aut']/." />
                  </xsl:when>
                  <xsl:when test="arr[@name='mods.nameByRole.personal.edt']">
                    <xsl:copy-of select="arr[@name='mods.nameByRole.personal.edt']/." />
                    <xsl:if test="arr[@name='mods.nameByRole.corporate.edt']">
                      <xsl:copy-of select="arr[@name='mods.nameByRole.corporate.edt']/." />
                    </xsl:if>
                  </xsl:when>
                  <xsl:when test="arr[@name='mods.nameByRole.corporate.pbl']">
                    <xsl:copy-of select="arr[@name='mods.nameByRole.corporate.pbl']/." />
                  </xsl:when>
                  <xsl:when test="arr[@name='mods.nameByRole.corporate.edt']">
                    <xsl:copy-of select="arr[@name='mods.nameByRole.corporate.edt']/." />
                  </xsl:when>
                </xsl:choose>
              </xsl:variable>
              <xsl:for-each select="exslt:node-set($nameList)/arr/str[position() &lt;= 3]">
                <xsl:if test="position()!=1">
                  <xsl:value-of select="' / '" />
                </xsl:if>
                <xsl:variable name="author_name">
                  <xsl:choose>
                    <xsl:when test="contains(., ':')">
                      <xsl:value-of select="substring-before(., ':')" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="." />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:variable name="nameIdentifierAndType" select="substring-after(., ':')" />
                <xsl:choose>
                  <xsl:when test="string-length($nameIdentifierAndType) &gt; 0">
                    <xsl:variable name="nameIdentifier" select="substring-after($nameIdentifierAndType, ':')" />
                    <xsl:variable name="nameIdentifierType" select="substring-before($nameIdentifierAndType, ':')" />
                    <xsl:variable name="classi"
                      select="document(concat('classification:metadata:all:children:','nameIdentifier',':',$nameIdentifierType))/mycoreclass/categories/category[@ID=$nameIdentifierType]" />
                    <xsl:variable name="uri" select="$classi/label[@xml:lang='x-uri']/@text" />
                    <xsl:variable name="idType" select="$classi/label[@xml:lang='de']/@text" />
                    <xsl:variable name="nameQuery" select="concat('mods.nameIdentifier:', $nameIdentifierType, '\:', $nameIdentifier)" />
                    <a
                      href="{$ServletsBaseURL}solr/mods_nameIdentifier?q={encoder:encode($nameQuery)}&amp;owner=createdby:{$owner}"
                      title="Suche nach allen Publikationen"
                    >
                      <xsl:value-of select="$author_name" />
                    </a>
                    <xsl:text>&#160;</xsl:text><!-- add whitespace here -->
                    <a href="{$uri}{$nameIdentifier}" title="Link zu {$idType}">
                      <sup>
                        <xsl:value-of select="$idType" />
                      </sup>
                    </a>
                  </xsl:when>
                  <xsl:otherwise>
                    <a href="{$ServletsBaseURL}solr/mods_nameIdentifier?q=mods.name:&quot;{$author_name}&quot;&amp;owner=createdby:{$owner}" title="Suche nach allen Publikationen">
                      <xsl:value-of select="$author_name" />
                    </a>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
              <xsl:if test="count(exslt:node-set($nameList)/arr/str) &gt; 3">
                <xsl:value-of select="' / et.al.'" />
              </xsl:if>
            </div>
          </xsl:if>

<!-- hit parent -->
          <xsl:if test="./str[@name='parent']">
            <div class="hit_source">
              <span class="label_parent">aus: </span>
              <xsl:choose>
                <xsl:when test="./str[@name='parentLinkText']">
                  <xsl:variable name="linkTo" select="concat($WebApplicationBaseURL, 'receive/',./str[@name='parent'])" />
                  <a href="{$linkTo}">
                    <xsl:value-of select="./str[@name='parentLinkText']" />
                  </a>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="objectLink">
                    <xsl:with-param select="./str[@name='parent']" name="obj_id" />
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </div>
          </xsl:if>

<!-- hit abstract -->
          <xsl:variable name="description">
            <xsl:choose>
              <xsl:when test="arr[@name=concat('mods.abstract.result.', $CurrentLang)]/str">
                <xsl:value-of select="arr[@name=concat('mods.abstract.result.', $CurrentLang)]/str[1]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="str[@name='mods.abstract.result']"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:if test="$description">
            <div class="hit_abstract">
              <xsl:value-of select="$description" />
            </div>
          </xsl:if>

<!-- hit publisher -->
          <xsl:if test="arr[@name='mods.publisher']">
            <div class="hit_pub_name">
              <xsl:variable name="date">
                <xsl:choose>
                  <xsl:when test="str[@name='mods.dateIssued']">
                    <xsl:value-of select="str[@name='mods.dateIssued']" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="str[@name='mods.dateIssued.host']" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="place" select="arr[@name='mods.place']/str" />
              <span class="label_publisher">
                <xsl:choose>
                  <xsl:when test="string-length($place) &gt; 0">
                    <xsl:value-of select="concat($place,': ')" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.published'),': ')" />
                  </xsl:otherwise>
                </xsl:choose>
              </span>

              <xsl:for-each select="arr[@name='mods.publisher']/str">
                <xsl:if test="position()!=1">
                  <xsl:value-of select="'; '" />
                </xsl:if>
                <xsl:value-of select="." />
                <xsl:if test="position()=last() and string-length($date) &gt; 0">
                  <xsl:value-of select="concat(', ', $date)" />
                </xsl:if>
              </xsl:for-each>
            </div>
          </xsl:if>
        </div><!-- end hit col -->
      </div><!-- end hit body -->
    </div><!-- end hit item -->
  </xsl:template>

  <xsl:template name="detectSearchParam">
    <xsl:param name="join" select="'?'" />
    <xsl:variable name="searchString">
      <xsl:variable name="queryPrefix" select="'{!join from=returnId to=id}+content:'" />
      <xsl:variable name="fullTextQuery"
                    select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='fq' and contains(., $queryPrefix)]" />
      <xsl:choose>
        <xsl:when test="$fullTextQuery">
          <xsl:value-of select="substring-after($fullTextQuery, $queryPrefix)" />
        </xsl:when>
        <xsl:when test="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='condQuery']">
          <xsl:value-of select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='condQuery']" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="string-length(normalize-space($searchString))&gt;0 and $searchString!='*'">
      <xsl:value-of select="concat($join, 'q=', $searchString)" />
    </xsl:if>
  </xsl:template>

  <!-- copied from mods.xsl -> ToDo: refacture! -->
  <xsl:template name="mods.getObjectEditURL">
    <xsl:param name="id" />
    <xsl:param name="layout" select="'$'" />
    <xsl:param name="collection" select="''" />
    <xsl:choose>
      <xsl:when test="mcrxsl:resourceAvailable('actionmappings.xml')">
      <!-- URL mapping enabled -->
        <xsl:variable name="url">
          <xsl:choose>
            <xsl:when test="string-length($collection) &gt; 0">
              <xsl:choose>
                <xsl:when test="$layout = 'all'">
                  <xsl:value-of select="actionmapping:getURLforCollection('update-xml',$collection,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="actionmapping:getURLforCollection('update',$collection,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$layout = 'all'">
                  <xsl:value-of select="actionmapping:getURLforID('update-xml',$id,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="actionmapping:getURLforID('update',$id,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="string-length($url)=0" />
          <xsl:otherwise>
            <xsl:call-template name="UrlSetParam">
              <xsl:with-param name="url" select="$url" />
              <xsl:with-param name="par" select="'id'" />
              <xsl:with-param name="value" select="$id" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
      <!-- URL mapping disabled -->
        <xsl:choose>
          <xsl:when test="$layout != '$'">
            <xsl:value-of select="concat($WebApplicationBaseURL,'/editor/editor-dynamic.xed?id=',$id,'&amp;genre=article&amp;host=standalone')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($WebApplicationBaseURL,'/editor/editor-admin.xed?id=',$id)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="print.classiFilter">
    <xsl:param name="classId" />
    <xsl:param name="i18nKey" />
    <div class="card">
      <xsl:variable name="classiDocument" select="document(concat('xslStyle:items2options:classification:editor:-1:children:',$classId))" />
      <div class="card-header" data-toggle="collapse-next">
        <h3 class="card-title">
          <xsl:value-of select="i18n:translate($i18nKey)" />
        </h3>
      </div>
      <div class="card-body collapse show">
        <xsl:if test="contains($RequestURL, concat('category.top%3A%22',$classId))">
          <div class="list-group">
            <xsl:apply-templates select="$classiDocument/select/option" mode="calculate_option_selected">
              <xsl:with-param name="classId" select="$classId" />
            </xsl:apply-templates>
          </div>
        </xsl:if>
        <div class="dropdown">
          <button class="btn btn-secondary dropdown-toggle col-12" type="button" data-bs-toggle="dropdown">
            <!--Filter-->
            <xsl:value-of select="i18n:translate('mir.response.button.filter')" />
            <span class="caret" />
          </button>
          <ul class="dropdown-menu dropdown-menu-end" style="max-height: 500px; overflow-y: scroll;">
            <xsl:apply-templates select="$classiDocument/select/option" mode="calculate_option_notselected">
              <xsl:with-param name="classId" select="$classId" />
            </xsl:apply-templates>
          </ul>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="select/option" mode="calculate_option_notselected">
    <xsl:param name="classId" />
    <xsl:variable name="complete">
      <xsl:value-of select="concat('%2Bcategory.top%3A%22',$classId,'%5C%3A',@value,'%22')" />
    </xsl:variable>
    <xsl:if test="not(contains($RequestURL, $complete))">
      <xsl:variable name="filterHref">
        <xsl:choose>
          <xsl:when test="contains($RequestURL,'&amp;')">
            <xsl:value-of select="concat(substring-before($RequestURL, '&amp;'), $complete, substring-after($RequestURL, substring-before($RequestURL, '&amp;')))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($RequestURL,$complete)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <li>
        <xsl:call-template name="print.hyperLink">
          <xsl:with-param name="href" select="mcrxsl:regexp($filterHref,'(&amp;|%26)(start=)[0-9]*', '')" />
          <xsl:with-param name="text" select="@title" />
          <xsl:with-param name="class" select="'dropdown-item'" />
        </xsl:call-template>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="select/option" mode="calculate_option_selected">
    <xsl:param name="classId" />
    <xsl:variable name="complete">
      <xsl:value-of select="concat('%2Bcategory.top%3A%22',$classId,'%5C%3A',@value,'%22')" />
    </xsl:variable>
    <xsl:if test="contains($RequestURL, $complete)">
      <xsl:variable name="filterHref">
        <xsl:value-of
          select="mcrxsl:regexp(concat(substring-before($RequestURL, $complete), substring-after($RequestURL, $complete)), '(&amp;|%26)(start=)[0-9]*', '')" />
      </xsl:variable>
      <xsl:call-template name="print.hyperLink">
        <xsl:with-param name="href" select="$filterHref" />
        <xsl:with-param name="text" select="@title" />
        <xsl:with-param name="class" select="'list-group-item active'" />
        <xsl:with-param name="icon" select="'times'" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="print.hyperLink">
    <xsl:param name="href" />
    <xsl:param name="text" />
    <xsl:param name="class" select="''" />
    <xsl:param name="icon" select="''" />
    <a class="{$class}" href="{$href}" title="{$text}">
      <xsl:if test="$icon != ''">
        <span aria-hidden="true" class="fas fa-{$icon}"></span>
      </xsl:if>
      <xsl:value-of select="$text" />
    </a>
  </xsl:template>

  <xsl:template name="print.dateFilter">
    <div class="card mir-search-options-date">
      <div class="card-header" data-toggle="collapse-next">
        <h3 class="card-title">
          <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.dateIssued')" />
        </h3>
      </div>
      <div class="card-body collapse show">
        <xsl:if test="contains($RequestURL, 'fq=mods.dateIssued')">
          <xsl:variable name="dateFilterHelper">
            <xsl:value-of select="substring-before($RequestURL, '&amp;fq=mods.dateIssued')" />
          </xsl:variable>
          <xsl:variable name="dateFilter">
            <xsl:choose>
              <xsl:when test="contains(substring-after($RequestURL, '&amp;fq=mods.dateIssued'), '&amp;')">
                <xsl:value-of select="concat($dateFilterHelper, '&amp;', substring-after(substring-after($RequestURL, '&amp;fq=mods.dateIssued'), '&amp;'))"></xsl:value-of>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$dateFilterHelper"></xsl:value-of>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <div class="list-group">
            <a class="list-group-item active" href="{$dateFilter}">
              <span aria-hidden="true" class="fas fa-times" />
            </a>
          </div>
        </xsl:if>
        <div class="dropdown">
          <button class="btn btn-secondary dropdown-toggle col-12" type="button" data-bs-toggle="dropdown">
            <!--Filter-->
            <xsl:value-of select="i18n:translate('mir.response.button.filter')" />
            <span class="caret" />
          </button>
          <div class="dropdown-menu dropdown-menu-end stopAutoclose col-md-12 mir-date-arrowTop" role="menu">
            <div class="container-fluid">
              <div class="col-md-12 mir-form-group">
                <select aria-label="select operator" class="form-control form-select">
                  <option value="=">=</option>
                  <option value="&gt;">&gt;</option>
                  <option value="&gt;=">&gt;=</option>
                  <option value="&lt;">&lt;</option>
                  <option value="&lt;=">&lt;=</option>
                </select>
              </div>
              <div class="col-md-12 mir-form-group dateContainer">
                <div class="col-md-4">
                  <input aria-label="Day" class="form-control" placeholder="DD" type="number" min="1" max="31" style="padding: 0.4em" />
                </div>
                <div class="col-md-4">
                  <input aria-label="Month" class="form-control" placeholder="MM" type="number" min="1" max="12" style="padding: 0.4em" />
                </div>
                <div class="col-md-4">
                  <input aria-label="Year" class="form-control" placeholder="YYYY" type="number" min="1000" max="2050" style="padding: 0.1em" />
                </div>
              </div>
              <div class="col-md-12 mir-form-group">
                <input aria-label="input for search date" id="dateSearch" type="button" class="btn btn-secondary form-control" value="Go!" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="basketLink">
    <xsl:param name="identifier" />
    <xsl:param name="dropdown" />

    <xsl:variable name="dropdownclass">
      <xsl:choose>
        <xsl:when test="$dropdown = 'true'">
          <xsl:value-of select="'dropdown-item'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="basket:contains('objects',$identifier)">
        <!-- remove from basket -->
        <a
          class="hit_option remove_from_basket {$dropdownclass}"
          href="{$ServletsBaseURL}MCRBasketServlet?type=objects&amp;action=remove&amp;id={$identifier}&amp;redirect=referer"
          title="" >
          <span class="fas fa-bookmark"></span>&#160;
          <xsl:value-of select="i18n:translate('basket.remove')" />
        </a>
      </xsl:when>
      <xsl:otherwise>
        <!-- add to basket -->
        <a
          class="hit_option hit_to_basket {$dropdownclass}"
          href="{$ServletsBaseURL}MCRBasketServlet?type=objects&amp;action=add&amp;id={$identifier}&amp;uri=mcrobject:{$identifier}&amp;redirect=referer"
          title="" >
          <span class="fas fa-bookmark"></span>&#160;
          <xsl:value-of select="i18n:translate('basket.add')" />
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="substring-after-last">
    <xsl:param name="string" />
    <xsl:param name="delimiter" />
    <xsl:choose>
      <xsl:when test="contains($string, $delimiter)">
        <xsl:call-template name="substring-after-last">
          <xsl:with-param name="string" select="substring-after($string, $delimiter)" />
          <xsl:with-param name="delimiter" select="$delimiter" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
