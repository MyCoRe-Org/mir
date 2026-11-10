<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:mcrurl="http://www.mycore.de/xslt/url"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/MyCoReLayout.xsl" />
  <xsl:include href="resource:xslt/solr/response/response-utils.xsl" />
  <xsl:include href="xslInclude:solrResponse" />

  <xsl:decimal-format name="european" decimal-separator="," grouping-separator="." />

  <xsl:variable
    name="hide_button_regex"
    select="mcrproperty:get('MIR.Search.PersonIndex.HideButtonRegex') = 'true'"
    as="xs:boolean"/>

  <xsl:variable name="PageTitle">
    <xsl:value-of select="mcri18n:translate('component.solr.searchresult.resultList')" />
  </xsl:variable>
  <xsl:variable name="numFound">
    <xsl:choose>
      <xsl:when test="contains($isSearchAllowedForCurrentUser, 'true')">
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
        <xsl:value-of select="mcri18n:translate('pindex.noObject')" />
      </xsl:when>
      <xsl:when test="$numFound=1">
        <xsl:value-of select="mcri18n:translate('pindex.oneObject')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of
          select="mcri18n:translate-with-params('pindex.nObjects', format-number($numFound, '###.###', 'european'))" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="termsRegex" select="/response/lst[@name='responseHeader']/lst[@name='params']/str[@name='regex']" />

  <xsl:variable name="retainedParams">
    <xsl:for-each select="./response/lst[@name='responseHeader']/lst[@name='params']/str[not(@name='start' or @name='rows')]">
      <xsl:value-of select="concat(@name, '=', replace(encode-for-uri(string(.)), '%20', '+'))" />
      <xsl:if test="not(position() = last())">
        <xsl:value-of select="'&amp;'" />
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <xsl:template match="lst[@name='mods.pindexname'] | lst[@name='mods.pindexname.published']">
    <xsl:for-each select="int">
      <xsl:sort select="@name" />

      <xsl:variable name="tokenizedTerm" select="tokenize(@name, '\|')" as="xs:string*"/>

      <xsl:variable name="encodedLinkText" select="$tokenizedTerm[last()-1]" as="xs:string"/>
      <xsl:variable name="nameIdentifierAndType" select="$tokenizedTerm[last()]" as="xs:string"/>

      <xsl:choose>
        <xsl:when test="string-length($nameIdentifierAndType) &gt; 0">
          <xsl:variable name="nameIdentifier" select="substring-after($nameIdentifierAndType, ':')" />
          <xsl:variable name="nameIdentifierType" select="substring-before($nameIdentifierAndType, ':')" />
          <xsl:variable name="classi"
            select="document(concat('classification:metadata:all:children:', 'nameIdentifier', ':', $nameIdentifierType))/mycoreclass/categories/category[@ID=$nameIdentifierType]" />
          <xsl:variable name="uri" select="$classi/label[@xml:lang='x-uri']/@text" />
          <xsl:variable name="idType" select="$classi/label[@xml:lang='de']/@text" />
          <xsl:variable name="nameQuery" select="concat('mods.nameIdentifier:', $nameIdentifierType, '\:', $nameIdentifier)" />
          <li>
            <a
              href="{$ServletsBaseURL}solr/mods_nameIdentifier?q={replace(encode-for-uri($nameQuery), '%20', '+')}"
              title="Suche nach allen Publikationen">
              <xsl:value-of select="mcrurl:decode-from-uri($encodedLinkText)" />
            </a>
            <xsl:text>&#160;</xsl:text>
            <a href="{$uri}{$nameIdentifier}" title="Link zu {$idType}">
              <sup>
                <xsl:value-of select="$idType" />
              </sup>
            </a>
          </li>
        </xsl:when>
        <xsl:otherwise>
          <li>
            <a href="{$ServletsBaseURL}solr/mods_nameIdentifier?q=mods.name:&quot;{$encodedLinkText}&quot;"
               title="Suche nach allen Publikationen">
              <xsl:value-of select="mcrurl:decode-from-uri($encodedLinkText)" />
            </a>
          </li>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="/response">

    <xsl:variable name="a2z">
      <A search="a.*" />
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
      <O search="o.*" />
      <P search="p.*" />
      <Q search="q.*" />
      <R search="r.*" />
      <S search="s.*" />
      <T search="t.*" />
      <U search="u.*" />
      <V search="v.*" />
      <W search="w.*" />
      <X search="x.*" />
      <Y search="y.*" />
      <Z search="z.*" />
      <other label="…" search="[^a-z].*" />
    </xsl:variable>

    <div class="row">
      <div class="col-md-12">

        <div class="row">
          <div class="col-md-4">
            <h2><xsl:value-of select="mcri18n:translate('browse.person.foundPersons')" /></h2>

            <xsl:choose>
              <xsl:when test="lst[@name='terms']/lst[@name='mods.pindexname']/int or
                              lst[@name='terms']/lst[@name='mods.pindexname.published']/int">
                <ul id="resultList">
                  <xsl:choose>
                    <xsl:when test="mcracl:is-current-user-in-role('editor') or mcracl:is-current-user-in-role('admin')">
                      <xsl:apply-templates select="lst[@name='terms']/lst[@name='mods.pindexname']" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:apply-templates select="lst[@name='terms']/lst[@name='mods.pindexname.published']" />
                    </xsl:otherwise>
                  </xsl:choose>
                </ul>
              </xsl:when>
              <xsl:otherwise>
                <p><xsl:value-of select="mcri18n:translate('browse.person.personNotFound')" /></p>
              </xsl:otherwise>
            </xsl:choose>
          </div>

          <div class="col-md-4">
            <h3><xsl:value-of select="mcri18n:translate('browse.person.firstLetter')" /></h3>
            <ul class="names">
              <xsl:for-each select="$a2z/*">
                <li>
                  <xsl:variable name="label" select="if (@label) then @label else name()" as="xs:string"/>
                  <xsl:choose>
                    <xsl:when test="$termsRegex = @search">
                      <xsl:attribute name="class">active</xsl:attribute>
                      <a href="{concat($proxyBaseURL,'?XSL.Style=person&amp;regex=.*')}">
                        <xsl:value-of select="$label"/>
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a href="{concat($proxyBaseURL,'?XSL.Style=person&amp;regex=',encode-for-uri(@search))}">
                        <xsl:value-of select="$label"/>
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:if test="position() != last()">
                    <span> | </span>
                  </xsl:if>
                </li>
              </xsl:for-each>
            </ul>
          </div>

          <div class="col-md-4">
            <h3><xsl:value-of select="mcri18n:translate('browse.person.searchPerson')" /></h3>

            <form id="index_search_form"
                  method="get"
                  action="{$proxyBaseURL}">
              <xsl:for-each
                select="lst[@name='responseHeader']/lst[@name='params']/str[not(@name='regex')]">
                <input type="hidden" name="{@name}" value="{.}" />
              </xsl:for-each>

              <xsl:variable
                name="search_value"
                select="if($hide_button_regex and $a2z/*[@search=$termsRegex]) then '' else $termsRegex"/>

              <xsl:variable name="placeholder">
                <xsl:value-of select="mcri18n:translate('browse.person.searchplaceholder')" />
              </xsl:variable>

              <label class="sr-only form-label" for="index_search">Gesuchte Zeichen</label>
              <div class="input-group">
                <input value="{$search_value}"
                       name="regex"
                       class="search_text_gray focus_form_field form-control"
                       id="index_search"
                       type="text"
                       placeholder="{$placeholder}" />
                <button type="submit"
                       class="btn btn-secondary search_button"
                       value="Suchen"
                       tabindex="1">
                  <xsl:value-of select="mcri18n:translate('button.search')" />
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

  </xsl:template>

</xsl:stylesheet>
