<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mcr="http://www.mycore.org/" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:encoder="xalan://java.net.URLEncoder"
  exclude-result-prefixes="xlink mcr i18n xsl">
  <xsl:import href="xslImport:modsmeta:metadata/mir-browse.xsl" />
  <xsl:include href="response-utils.xsl" />
  <xsl:template match="/">
    <div id="search_options">
      <xsl:apply-templates select="/mycoreobject/response" />
    </div>
    <xsl:apply-imports />
  </xsl:template>

  <xsl:template match="/mycoreobject/response">
    <xsl:variable name="ResultPages">
      <xsl:call-template name="solr.Pagination">
        <xsl:with-param name="href" select="concat($proxyBaseURL,$HttpSession,$solrParams)" />
        <xsl:with-param name="size" select="$rows" />
        <xsl:with-param name="currentpage" select="$currentPage" />
        <xsl:with-param name="totalpage" select="$totalPages" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="params">
      <xsl:for-each select="/response/lst[@name='responseHeader']/lst[@name='params']/str">
        <xsl:choose>
          <xsl:when test="@name='rows' or @name='XSL.Style' or @name='fl' or @name='start'">
        <!-- skip them -->
          </xsl:when>
          <xsl:when test="@name='origrows' or @name='origXSL.Style' or @name='origfl'">
        <!-- ParameterName=origParameterValue -->
            <xsl:value-of select="concat(substring-after(@name, 'orig'),'=', encoder:encode(., 'UTF-8'))" />
            <xsl:if test="not (position() = last())">
              <xsl:value-of select="'&amp;'" />
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
        <!-- parameterName=parameterValue -->
            <xsl:value-of select="concat(@name,'=', encoder:encode(., 'UTF-8'))" />
            <xsl:if test="not (position() = last())">
              <xsl:value-of select="'&amp;'" />
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <div class="row pager_plus">
      <div class="col-xs-2 pager_option pager_option_left">
        <button type="button" class="btn btn-default">Suche verfeinern</button>
      </div>
      <div class="col-xs-8">
        <xsl:copy-of select="$ResultPages" />
      </div>
      <div class="col-xs-2 pager_option pager_option_right">
          <button type="button" class="btn btn-default">Trefferliste anzeigen</button>
      </div>
    </div>

       <!--
          <xsl:variable name="origRows" select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='origrows']" />
          <xsl:variable name="newStart" select="$start - $start mod $origRows" />
          <xsl:variable name="href" select="concat($proxyBaseURL,'?', $HttpSession, $params, '&amp;start=', $newStart)" />

          <a href="{$href}">
            <xsl:value-of select="i18n:translate('component.solr.searchresult.back')" />
          </a>
        -->
    <xsl:variable name="objId" select="/mycoreobject/@ID" />
    <xsl:variable name="staticUrl" select="concat($WebApplicationBaseURL, 'receive/', $objId)" />
    <div id="permalink">
      <span class="linklabel">
        <xsl:value-of select="concat(i18n:translate('component.solr.searchresult.objectlink'), ' : ')" />
      </span>
      <span class="linktext">
        <xsl:variable name="linkToDocument">
          <xsl:value-of select="$staticUrl" />
        </xsl:variable>
        <a href="{concat($staticUrl,$HttpSession)}">
          <xsl:value-of select="$staticUrl" />
        </a>
      </span>
    </div>
    <!-- change url in browser -->
    <script type="text/javascript">
      <xsl:value-of select="concat('var pageurl = &quot;', $staticUrl, '&quot;;')" />
      if(typeof window.history.replaceState == &quot;function&quot;){
        var originalPage = {title: document.title, url: document.location.toString()};
        window.history.replaceState({path:pageurl},&quot; <xsl:value-of select="i18n:translate('component.solr.searchresult.resultList')" /> &quot;,pageurl);
        document.getElementById(&quot;permalink&quot;).style.display = &quot;none&quot;;
        window.onbeforeunload = function(){
          window.history.replaceState({path:originalPage.url}, originalPage.title, originalPage.url);
        }
      }
    </script>
  </xsl:template>
</xsl:stylesheet>