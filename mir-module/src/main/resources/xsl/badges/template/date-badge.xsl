<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:exslt="http://exslt.org/common"
                xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
                exclude-result-prefixes="i18n xsl mods mcrxsl exslt mcrxml">

  <xsl:include href="resource:xsl/badges/template/create-badge-util.xsl" />

  <!-- Date badge -->
  <xsl:template name="date-badge">
    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />

    <xsl:variable name="owner">
      <xsl:choose>
        <xsl:when test="mcrxml:isCurrentUserInRole('admin') or mcrxml:isCurrentUserInRole('editor')">
          <xsl:text>*</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$CurrentUser"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:for-each select="$mods/mods:genre[@type='kindof']|$mods/mods:genre[@type='intern']">
      <xsl:variable name="dateIssued">
        <xsl:choose>
          <xsl:when test="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf']">
            <xsl:choose>
              <xsl:when test="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf' and @point]">
                <xsl:apply-templates mode="mods.datePublished" select="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf' and @point='start']" />
                <xsl:text>|</xsl:text>
                <xsl:apply-templates mode="mods.datePublished" select="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf' and @point='end']" />
              </xsl:when>
              <xsl:when test="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf' and not(@point)]">
                <xsl:apply-templates mode="mods.datePublished" select="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf']" />
              </xsl:when>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$mods/mods:relatedItem/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf']"><xsl:apply-templates mode="mods.datePublished" select="$mods/mods:relatedItem/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf']" />
          </xsl:when>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="firstDate">
        <xsl:for-each select="$mods/mods:originInfo[not(@eventType) or @eventType='publication']/mods:dateIssued[@encoding='w3cdtf']">
          <xsl:sort data-type="number" select="count(ancestor::mods:originInfo[not(@eventType) or @eventType='publication'])" />
          <xsl:if test="position()=1">
            <xsl:value-of select="." />
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <xsl:if test="string-length($dateIssued) > 0">
        <xsl:variable name="dateText">
          <xsl:variable name="date">
            <xsl:call-template name="Tokenizer"><!-- use split function from mycore-base/coreFunctions.xsl -->
              <xsl:with-param name="string" select="$dateIssued" />
              <xsl:with-param name="delimiter" select="'|'" />
            </xsl:call-template>
          </xsl:variable>
          <xsl:for-each select="exslt:node-set($date)/token">
            <xsl:if test="position()=2">
              <xsl:text> - </xsl:text>
            </xsl:if>
            <xsl:if test="mcrxsl:trim(.) != ''">
              <xsl:variable name="format">
                <xsl:choose>
                  <xsl:when test="string-length(normalize-space(.))=4">
                    <xsl:value-of select="i18n:translate('metaData.dateYear')" />
                  </xsl:when>
                  <xsl:when test="string-length(normalize-space(.))=7">
                    <xsl:value-of select="i18n:translate('metaData.dateYearMonth')" />
                  </xsl:when>
                  <xsl:when test="string-length(normalize-space(.))=10">
                    <xsl:value-of select="i18n:translate('metaData.dateYearMonthDay')" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="i18n:translate('metaData.dateTime')" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:call-template name="formatISODate">
                <xsl:with-param name="date" select="." />
                <xsl:with-param name="format" select="$format" />
              </xsl:call-template>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="dataAttributes">
          <xsl:attribute name="datetime">
            <xsl:value-of select="$dateIssued"/>
          </xsl:attribute>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$firstDate and $firstDate != ''">
            <xsl:call-template name="create-badge">
              <xsl:with-param name="label" select="$dateText" />
              <xsl:with-param name="color" select="'primary'" />
              <xsl:with-param name="class" select="'date_published'" />
              <xsl:with-param name="URL"
                              select="concat($ServletsBaseURL, 'solr/find?condQuery=*&amp;fq=mods.dateIssued:',
                $firstDate, '&amp;owner=createdby:', $owner)" />
              <xsl:with-param name="dataAttributes" select="$dataAttributes" />
              <xsl:with-param name="tooltip" select="i18n:translate('metaData.publicationDate')" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="create-badge">
              <xsl:with-param name="label" select="$dateText" />
              <xsl:with-param name="color" select="'primary'" />
              <xsl:with-param name="class" select="'date_published'" />
              <xsl:with-param name="dataAttributes" select="$dataAttributes" />
              <xsl:with-param name="tooltip" select="i18n:translate('metaData.publicationDate')" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
