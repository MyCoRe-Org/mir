<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:str="http://exslt.org/strings" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" exclude-result-prefixes="i18n mods str mcr acl mcrxsl encoder">

  <!-- retain the original query and parameters, for attaching them to a url -->
  <xsl:variable name="query">
    <xsl:if test="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='qry'] != '*'">
      <xsl:value-of select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='qry']" />
    </xsl:if>
  </xsl:variable>

  <xsl:template match="/response/result|lst[@name='grouped']/lst[@name='returnId']" priority="10">
    <xsl:variable name="ResultPages">
      <xsl:if test="$hits &gt; 0">
        <xsl:call-template name="solr.Pagination">
          <xsl:with-param name="size" select="$rows" />
          <xsl:with-param name="currentpage" select="$currentPage" />
          <xsl:with-param name="totalpage" select="$totalPages" />
          <xsl:with-param name="class" select="'pagination-sm'" />
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <div class="row result_head">
      <div class="col-xs-12 result_headline">
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
      <div class="col-xs-12 col-md-9 text-center result_search">
        <div class="search_box">
          <form action="{$WebApplicationBaseURL}servlets/solr/find" class="search_form" method="post">
            <div class="input-group input-group-sm">
              <div class="input-group-btn">
                <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" value="all" id="search_type_button"><span id="search_type_label">Alles</span> <span class="caret"></span></button>
                <ul class="dropdown-menu search_type">
                  <li><a href="#" value="all">Alles</a></li>
                  <li><a href="#" value="mods.title">Titel</a></li>
                  <li><a href="#" value="mods.author">Autor</a></li>
                  <li><a href="#" value="mods.name.top">Name</a></li>
                  <li><a href="#" value="mods.gnd">GND</a></li>
                  <li><a href="#" value="allMeta">Alle Metadaten</a></li>
                  <li><a href="#" value="content">Volltext</a></li>
                </ul>
              </div>
              <input class="form-control" name="qry" placeholder="ein oder mehrere Schlagworte" type="text" />
              <span class="input-group-btn">
                <button class="btn btn-primary" type="submit"><span class="glyphicon glyphicon-search"></span> Suchen</button>
              </span>
            </div>
          </form>
        </div>
      </div>
    </div> <!-- ENDE: Suchschlitz mit Suchbegriff -->

<!-- Filter, Pagination & Trefferliste -->
    <div class="row result_body">
      <div class="col-xs-12 col-sm-4 col-lg-3 result_filter">
        <xsl:if test="/response/lst[@name='facet_counts']/lst[@name='facet_fields'] and $hits &gt; 0">
          <div class="panel panel-default">
            <div class="panel-heading">
              <h3 class="panel-title">Typ</h3>
            </div>
            <div class="panel-body">
              <ul class="filter">
                <xsl:apply-templates select="/response/lst[@name='facet_counts']/lst[@name='facet_fields']">
                  <xsl:with-param name="facet_name" select="'mods.type'" />
                </xsl:apply-templates>
              </ul>
            </div>
          </div>
        </xsl:if>
      </div>

      <div class="cols-xs-12 col-sm-8 col-lg-9 result_list">
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

    </div>
  </xsl:template>

  <xsl:template match="doc" priority="10" mode="resultList">
    <xsl:param name="hitNumberOnPage" select="count(preceding-sibling::*[name()=name(.)])+1" />
    <!--
      Do not read MyCoRe object at this time
    -->
    <xsl:variable name="identifier" select="@id" />
    <xsl:variable name="mcrobj" select="." />
    <xsl:variable name="mods-type">
      <xsl:choose>
        <xsl:when test="str[@name='mods.type']">
          <xsl:value-of select="str[@name='mods.type']" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'article'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="mods-type-i18n" select="i18n:translate(concat('component.mods.genre.',$mods-type))" />
    <xsl:variable name="hitItemClass">
      <xsl:choose>
        <xsl:when test="$hitNumberOnPage mod 2 = 1">odd</xsl:when>
        <xsl:otherwise>even</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- generate browsing url -->
    <xsl:variable name="href" select="concat($proxyBaseURL,$HttpSession,$solrParams)" />
    <xsl:variable name="startPosition" select="$hitNumberOnPage - 1 + (($currentPage) -1) * $rows" />
    <xsl:variable name="hitHref">
      <xsl:value-of select="concat($href, '&amp;start=',$startPosition, '&amp;fl=id&amp;rows=1&amp;XSL.Style=browse')" />
    </xsl:variable>

    <!-- derivate variables -->
    <xsl:variable name="derivates" select="key('derivate', $identifier)" />
    <xsl:variable name="derivid"   select="$derivates/str[@name='maindoc'][1]/../str[@name='id']" />
    <xsl:variable name="maindoc"   select="$derivates/str[@name='maindoc'][1]" />
    <xsl:variable name="derivbase" select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derivid,'/')" />
    <xsl:variable name="derivifs"  select="concat($derivbase,$maindoc,$HttpSession)" />


<!-- hit entry -->
    <div class="hit_item {$hitItemClass}">

<!-- hit head -->
      <div class="row hit_item_head">
        <div class="col-xs-12">

<!-- hit number -->
          <div class="hit_counter">
            <xsl:value-of select="$hitNumberOnPage" />
          </div>

<!-- relevance -->
          <div class="hit_stars_5 hit_stars" title="ToDo: SolrScore"> <!-- ToDo: hit_stars_3 für nur 3 Sterne ... -->
            <div class="hit_star_1 hit_star"></div>
            <div class="hit_star_2 hit_star"></div>
            <div class="hit_star_3 hit_star"></div>
            <div class="hit_star_4 hit_star"></div>
            <div class="hit_star_5 hit_star"></div>
          </div>

<!-- hit options -->
          <div class="hit_options pull-right">
              <div class="btn-group">
                <a data-toggle="dropdown" class="btn btn-default dropdown-toggle" href="#"><i class="fa fa-cog"></i> Aktionen<span class="caret"></span></a>
                <ul class="dropdown-menu dropdown-menu-right">
                    <li class="">
                      <!-- add to basket -->
                      <a class="hit_option hit_to_basket"
                        href="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}?type=objects&amp;action=add&amp;id={$identifier}&amp;uri=mcrobject:{$identifier}&amp;redirect=referer"
                        title=""><span class="glyphicon glyphicon-shopping-cart"></span><xsl:value-of select="i18n:translate('basket.add')" /></a>
                    </li>
                    <!-- download main document of first derivate -->
                    <xsl:if test="not($derivates/str[@name='iviewFile']) and $derivates/str[@name='maindoc']">
                      <li class="">
                        <a class="hit_option hit_download" href="{$derivifs}" title=""><span class="glyphicon glyphicon-download-alt"></span><xsl:value-of select="$maindoc" /></a>
                      </li>
                    </xsl:if>
                    <!-- direct link to editor -->
                    <xsl:if test="acl:checkPermission($identifier,'writedb')" >
                      <li class="">
                        <xsl:variable name="editURL">
                          <xsl:call-template name="mods.getObjectEditURL">
                            <xsl:with-param name="id" select="$identifier" />
                            <xsl:with-param name="layout" select="'$'" />
                          </xsl:call-template>
                        </xsl:variable>
                        <a class="hit_option hit_edit">
                          <xsl:choose>
                            <xsl:when test="string-length($editURL) &gt; 0">
                              <xsl:attribute name="href">
                                <xsl:value-of select="$editURL" />
                              </xsl:attribute>
                              <span class="glyphicon glyphicon-pencil"></span>
                              <xsl:value-of select="i18n:translate('object.editObject')" />
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:attribute name="href">
                                <xsl:value-of select="'#'" />
                              </xsl:attribute>
                              <span class="glyphicon glyphicon-pencil"></span>
                              <xsl:value-of select="i18n:translate('object.locked')" />
                            </xsl:otherwise>
                          </xsl:choose>
                        </a>
                      </li>
                    </xsl:if>
                </ul>
            </div>
          </div>


        </div><!-- end col -->
      </div><!-- end row head -->


<!-- hit body -->
      <div class="row hit_item_body">
        <div class="col-xs-12">

<!-- document preview -->
          <div class="hit_download_box">
            <xsl:choose>

              <!-- we got a derivate -->
              <xsl:when test="string-length($derivid) &gt; 0">
                <xsl:choose>

                  <!-- show IView thumbnail as preview -->
                  <xsl:when test="$derivates/str[@name='iviewFile']">
                    <!-- xsl:call-template name="iViewLinkPrev">
                      <xsl:with-param name="mcrid" select="$identifier" />
                      <xsl:with-param name="derivate" select="$derivid" />
                      <xsl:with-param name="fileName" select="$derivates/str[@name='iviewFile'][1]" />
                    </xsl:call-template -->
                    <a class="hit_option hit_download" href="{$derivifs}" title="{$mods-type-i18n}">
                      <div class="hit_icon"
                           style="background-image: url('{$WebApplicationBaseURL}servlets/MCRTileCombineServlet/THUMBNAIL/{$derivid}/{$derivates/str[@name='iviewFile'][1]}');">
                      </div>
                    </a>
                  </xsl:when>

                  <!-- show PDF thumbnail as preview -->
                  <xsl:when test="str:tokenize($derivates/str[@name='maindoc'][1],'.')[position()=last()] = 'pdf'">
                    <a class="hit_option hit_download" href="{$derivifs}" title="{$mods-type-i18n}">
                      <xsl:variable name="filePath" select="concat($derivates/str[@name='id'][1],'/',mcr:encodeURIPath($derivates/str[@name='maindoc'][1]),$HttpSession)" />
                      <div class="hit_icon"
                           style="background-image: url('{$WebApplicationBaseURL}img/pdfthumb/{$filePath}?centerThumb=no');">
                      </div>
                    </a>
                  </xsl:when>

                  <!-- show default icon with mime-type download icon -->
                  <xsl:otherwise>
                    <a class="hit_option hit_download" href="{$derivifs}" title="">
                      <!-- xsl:variable name="contentType" select="document(concat('ifs:/',$derivid))/mcr_directory/children/child[name=$maindoc]/contentType" />
                      <xsl:variable name="fileType" select="document('webapp:FileContentTypes.xml')/FileContentTypes/type[@ID=$contentType]//extension" / -->
                      <xsl:variable name="fileType" select="'docx'" />
                      <div class="hit_icon" style="background-image: url('{$WebApplicationBaseURL}images/icons/icon_common.png');" />
                      <xsl:choose>
                        <xsl:when test="$fileType='pdf' or $fileType='msexcel' or $fileType='xlsx' or $fileType='msword97' or $fileType='docx'">
                          <img class="hit_icon_overlay" src="{$WebApplicationBaseURL}images/icons/download_{$fileType}.png" />
                        </xsl:when>
                        <xsl:otherwise>
                          <img class="hit_icon_overlay" src="{$WebApplicationBaseURL}images/icons/download_default.png" />
                        </xsl:otherwise>
                      </xsl:choose>
                    </a>
                  </xsl:otherwise>
                </xsl:choose>

              </xsl:when>

              <!-- no derivate -->
              <xsl:otherwise>
                <!-- show default icon -->
                <img class="hit_icon" src="{$WebApplicationBaseURL}images/icons/icon_common_disabled.png" />
              </xsl:otherwise>
            </xsl:choose>
          </div>

<!-- hit type -->
          <div class="hit_tnd_container">
            <div class="hit_tnd_content">
              <div class="hit_type">
                <span class="label label-info"><xsl:value-of select="$mods-type-i18n" /></span>
              </div>
              <xsl:if test="str[@name='mods.dateIssued']">
                <div class="hit_date">
                  <xsl:variable name="date">
                    <xsl:value-of select="str[@name='mods.dateIssued']" />
                  </xsl:variable>
                  <span class="label label-primary"><xsl:value-of select="$date" /></span>
                </div>
              </xsl:if>
            </div>
          </div>

<!-- hit headline -->
              <h3 class="hit_title">
                <a href="{$hitHref}">
                  <xsl:attribute name="title"><xsl:value-of select="./str[@name='mods.title']" /></xsl:attribute>
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
              <xsl:if test="./arr[@name='mods.author']">
                <div class="hit_author">
                  <xsl:for-each select="./arr[@name='mods.author']/str">
                    <xsl:if test="position()!=1">
                      <xsl:value-of select="' / '" />
                    </xsl:if>
                    <xsl:variable name="author_name" select="." />
                    <xsl:variable name="gnd">
                      <xsl:for-each select="../../arr[@name='mods.pindexname']/str">
                        <xsl:if test="contains(text(), $author_name)">
                          <xsl:value-of select="substring-after(text(), ':')" />
                        </xsl:if>
                      </xsl:for-each>
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="string-length($gnd) &gt; 0">
                        <a href="{$ServletsBaseURL}solr/mods_gnd?q={$gnd}" title="Suche nach allen Publikationen" >
                          <xsl:value-of select="$author_name" />
                        </a>
                        <xsl:text>&#160;</xsl:text><!-- add whitespace here -->
                        <a href="http://d-nb.info/gnd/{$gnd}" title="Link zur GND">
                          <sup>GND</sup>
                        </a>
                      </xsl:when>
                      <xsl:otherwise>
                        <a href="{$ServletsBaseURL}solr/mods_name?q='{$author_name}'" title="Suche nach allen Publikationen">
                          <xsl:value-of select="$author_name" />
                        </a>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
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
              <xsl:variable name="description" select="str[@name='mods.abstract.result']" />
              <xsl:if test="$description">
                <div class="hit_abstract">
                  <xsl:value-of select="$description" />
                </div>
              </xsl:if>

              <xsl:if test="arr[@name='mods.publisher']">
                <div class="hit_pub_name">
                  <span class="label_publisher">
                    <xsl:value-of select="concat(i18n:translate('component.mods.metaData.dictionary.published'),': ')" />
                  </span>
                  <xsl:variable name="publisher" select="arr[@name='mods.publisher']/str" />
                  <xsl:variable name="place" select="arr[@name='mods.place']/str" />
                  <xsl:for-each select="$publisher">
                    <xsl:if test="position()!=1">
                      <xsl:value-of select="'; '" />
                    </xsl:if>
                    <xsl:value-of select="$publisher" />
                  </xsl:for-each>
                  <xsl:if test="count($publisher)=1 and count($place)=1">
                    <xsl:value-of select="', '" />
                    <xsl:value-of select="$place" />
                  </xsl:if>
                </div>
              </xsl:if>

        </div><!-- end hit col -->
      </div><!-- end hit body -->
    </div><!-- end hit item -->
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
            <xsl:variable name="urlWithParam">
              <xsl:call-template name="UrlSetParam">
                <xsl:with-param name="url" select="$url"/>
                <xsl:with-param name="par" select="'id'"/>
                <xsl:with-param name="value" select="$id" />
              </xsl:call-template>
            </xsl:variable>
            <xsl:call-template name="UrlAddSession">
              <xsl:with-param name="url" select="$urlWithParam" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
      <!-- URL mapping disabled -->
        <xsl:choose>
          <xsl:when test="$layout != '$'">
            <xsl:value-of select="concat($WebApplicationBaseURL,'/editor/editor-dynamic.xed',$HttpSession,'?id=',$id,'&amp;genre=article&amp;host=standalone')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($WebApplicationBaseURL,'/editor/editor-admin.xed',$HttpSession,'?id=',$id)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/response/lst[@name='facet_counts']/lst[@name='facet_fields']">
    <xsl:param name="facet_name" />
    <xsl:for-each select="lst[@name=$facet_name]/int">
      <xsl:variable name="queryURL" select="concat($WebApplicationBaseURL,'servlets/solr/find?qry=', $query, ' +mods.type:%22', @name, '%22')" /> <!-- ,'&amp;', $params -->
      <li>
        <div class="checkbox">
          <label>
            <!-- TODO: use ajax and add filter remove options -->
            <input type="checkbox" onclick="location.href='{$queryURL}';" /><!-- {$queryURL} -->
          </label>
            <span class="title"><xsl:value-of select="i18n:translate(concat('component.mods.genre.',@name))" /></span>
            <span class="hits"><xsl:value-of select="." /></span>
        </div>
      </li>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>