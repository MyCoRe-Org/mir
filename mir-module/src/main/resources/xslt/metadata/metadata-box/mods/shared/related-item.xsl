<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="resource:xslt/layout/mir-layout-utils.xsl" />
  <xsl:import href="resource:xslt/metadata/metadata-box/mods/shared/extent.xsl" />

  <xsl:template name="related-item-by-id">
    <xsl:param name="parentID" />
    <xsl:param name="label" />

    <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem[@xlink:href=$parentID]">
      <xsl:call-template name="related-item-row">
        <xsl:with-param name="parentID" select="$parentID"/>
        <xsl:with-param name="label" select="$label"></xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="related-item-row">
    <xsl:param name="parentID" />
    <xsl:param name="label" />
    <tr>
      <td valign="top" class="metaname">
        <xsl:value-of select="concat($label,':')" />
      </td>
      <td class="metavalue">
        <!-- Parent/Host -->
        <xsl:choose>
          <xsl:when test="string-length($parentID)!=0">
            <xsl:call-template name="objectLink">
              <xsl:with-param select="$parentID" name="obj_id" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="mods:titleInfo/mods:title" />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text disable-output-escaping="yes">&lt;br /></xsl:text>
        <xsl:variable name="dateIssued">
          <xsl:choose>
            <xsl:when test="(./@type='host' or ./@type='series') and ../../mods:originInfo[@eventType='publication']/mods:dateIssued">
              <xsl:apply-templates select="../../mods:originInfo[@eventType='publication']/mods:dateIssued" mode="formatDate"/>
            </xsl:when>
            <xsl:when test="(./@type='host' or ./@type='series') and ../mods:originInfo[@eventType='publication']/mods:dateIssued">
              <xsl:apply-templates select="../mods:originInfo[@eventType='publication']/mods:dateIssued" mode="formatDate"/>
            </xsl:when>
            <xsl:when test="mods:originInfo[@eventType='publication']/mods:dateIssued">
              <xsl:apply-templates select="mods:originInfo[@eventType='publication']/mods:dateIssued" mode="formatDate"/>
            </xsl:when>
            <xsl:when test="mods:part/mods:date">
              <xsl:apply-templates select="mods:part/mods:date" mode="formatDate"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <!-- Volume -->
        <xsl:if test="mods:part/mods:detail[@type='volume']/mods:number">
          <xsl:value-of
            select="concat(mcri18n:translate('component.mods.metaData.dictionary.volume.shortcut'),' ',mods:part/mods:detail[@type='volume']/mods:number)" />
          <xsl:if test="mods:part/mods:detail[@type='issue']/mods:number">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:if>
        <!-- Issue -->
        <xsl:if test="mods:part/mods:detail[@type='issue']/mods:number">
          <xsl:value-of
            select="concat(mcri18n:translate('component.mods.metaData.dictionary.issue.shortcut'),' ',mods:part/mods:detail[@type='issue']/mods:number)" />
        </xsl:if>
        <xsl:if test="mods:part/mods:detail[@type='issue']/mods:number or mods:part/mods:detail[@type='volume']/mods:number and string-length($dateIssued) &gt; 0">
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="string-length($dateIssued) &gt; 0">
          <xsl:text>(</xsl:text>
          <xsl:value-of select="$dateIssued" />
          <xsl:text>)</xsl:text>
        </xsl:if>
        <!-- Articlenumber -->
        <xsl:if test="mods:part/mods:detail[@type='article_number']/mods:number">
          <xsl:value-of
            select="concat(mcri18n:translate('mir.articlenumber.short'),mods:part/mods:detail[@type='article_number']/mods:number)" />
        </xsl:if>
        <!-- Pages -->
        <xsl:if test="mods:part/mods:extent[@unit='pages']">
          <xsl:text>, </xsl:text>
          <xsl:for-each select="mods:part/mods:extent[@unit='pages']">
            <xsl:call-template name="format-extent" />
          </xsl:for-each>
        </xsl:if>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
