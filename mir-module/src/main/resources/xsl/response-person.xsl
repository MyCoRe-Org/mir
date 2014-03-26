<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY html-output SYSTEM "xsl/xsl-output-html.fragment">
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:xalan="http://xml.apache.org/xalan" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" exclude-result-prefixes="xalan i18n encoder">
  &html-output;
  <xsl:include href="MyCoReLayout.xsl" />
  <xsl:include href="response-utils.xsl" />
  <xsl:include href="xslInclude:solrResponse" />

  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="MCR.Results.FetchHit" />

  <xsl:decimal-format name="european" decimal-separator=',' grouping-separator='.' />

  <xsl:variable name="PageTitle">
    <xsl:value-of select="i18n:translate('component.solr.searchresult.resultList')" />
  </xsl:variable>

  <xsl:variable name="numFound">
    <xsl:choose>
      <xsl:when test="mcrxsl:isCurrentUserInRole('editor') or mcrxsl:isCurrentUserInRole('admin')">
        <xsl:value-of select="count(/response/lst[@name='terms']/lst[@name='mods.pindexname']/int)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count(/response/lst[@name='terms']/lst[@name='mods.pindexname.published']/int)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="resultsText">
    <xsl:choose>
      <xsl:when test="$numFound=0">
        <xsl:value-of select="i18n:translate('pindex.noObject')" />
      </xsl:when>
      <xsl:when test="$numFound=1">
        <xsl:value-of select="i18n:translate('pindex.oneObject')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="i18n:translate('pindex.nObjects',format-number($numFound, '###.###', 'european'))" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- retain the original query parameters, for attaching them to a url -->
  <xsl:variable name="params">
    <xsl:for-each select="./response/lst[@name='responseHeader']/lst[@name='params']/str[not(@name='start' or @name='rows')]">
      <!-- parameterName=parameterValue -->
      <xsl:value-of select="concat(@name,'=', encoder:encode(., 'UTF-8'))" />
      <xsl:if test="not (position() = last())">
        <xsl:value-of select="'&amp;'" />
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:template match="int">
    <xsl:variable name="gnd" select="substring-after(@name, ':')" />

    <xsl:variable name="linkText">
      <xsl:choose>
        <xsl:when test="contains(@name, ':')">
          <xsl:value-of select="substring-before(@name, ':')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@name" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="linkTo">
      <xsl:choose>
        <xsl:when test="string-length($gnd)>0">
          <xsl:value-of select="concat($ServletsBaseURL, 'solr/mods_gnd?q=', $gnd)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($ServletsBaseURL, 'solr/mods_name?q=%22', $linkText, '%22')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="toolTip">
      <xsl:choose>
        <xsl:when test="$gnd">
          <xsl:value-of select="$gnd" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$linkText" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <tr>
      <td class="resultTitle" colspan="2">
        <a href="{$linkTo}" title="{$toolTip}">
          <xsl:value-of select="$linkText" />
        </a>
        <xsl:if test="string-length($gnd)>0">
          <a title="http://d-nb.info/gnd/{$gnd}" href="http://d-nb.info/gnd/{$gnd}" class="gnd">
            GND
          </a>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="/response">

    <div class="blockbox" id="person_index">

      <p>Personenindex von A bis Z</p>

      <xsl:variable name="a2z">
        <A search="[a|ä].*" />
        <B search="b.*" />
        <C search="c.*" />
        <D search="d.*" />
        <E search="e.*" />
        <F search="f.*" />
        <G search="g.*" />
        <H search="h.*" />
        <I search="i.*" />
        <J search="j.*" />
        <K search="k.*" />
        <L search="l.*" />
        <M search="m.*" />
        <N search="n.*" />
        <O search="[o|ö].*" />
        <P search="p.*" />
        <Q search="q.*" />
        <R search="r.*" />
        <S search="s.*" />
        <T search="t.*" />
        <U search="[u|ü].*" />
        <V search="v.*" />
        <W search="w.*" />
        <X search="x.*" />
        <Y search="y.*" />
        <Z search="z.*" />
      </xsl:variable>
      <ul class="names">
        <xsl:for-each select="xalan:nodeset($a2z)/*">
          <li>
            <a href="{concat($proxyBaseURL,$HttpSession, '?XSL.Style=person&amp;terms.regex=', @search)}">
              <xsl:value-of select="name()" />
            </a>
            <xsl:if test="position() != last()">
              <xsl:text> |</xsl:text>
            </xsl:if>
          </li>
        </xsl:for-each>
      </ul>

      <form action="{concat($proxyBaseURL,$HttpSession)}" method="get" id="index_search_form" class="yform full">
        <xsl:for-each
          select="lst[@name='responseHeader']/lst[@name='params']/str[not(@name='terms.regex')]">
          <input type="hidden" name="{@name}" value="{.}" />
        </xsl:for-each>
        <div class="subcolumns">
          <div class="c60l">
            <div>
              <div class="type-text">
                <input id="index_search" class="search_text_gray focus_form_field" type="text" name="terms.regex" value="{$query}" />
              </div>
            </div>
          </div>
          <div class="c40r">
            <div>
              <button type="submit" tabindex="1" class="search_button" value="Suchen">Suchen</button>
            </div>
          </div>
        </div>
      </form>

      <!-- results -->
      <table id="resultList">
        <xsl:choose>
          <xsl:when test="mcrxsl:isCurrentUserInRole('editor') or mcrxsl:isCurrentUserInRole('admin')">
            <xsl:apply-templates select="lst[@name='terms']/lst[@name='mods.pindexname']/int" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="lst[@name='terms']/lst[@name='mods.pindexname.published']/int" />
          </xsl:otherwise>
        </xsl:choose>
      </table>
  </div>

  </xsl:template>

</xsl:stylesheet>