<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="i18n">

  <xsl:import href="xslImport:modsmeta:metadata/mir-history.xsl" />  
  
  <xsl:template match="/">
    <xsl:variable name="ID" select="/mycoreobject/@ID" />
    <xsl:variable name="verinfo" select="document(concat('versioninfo:',$ID))" />
    <div id="mir-historydata" class="table-responsive col-sm-12">
      <table class="table table-hover table-condensed">
        <tr class="info">
          <th>
            <xsl:value-of select="i18n:translate('metadata.versionInfo.version')" />
          </th>
          <th>
            <xsl:value-of select="i18n:translate('metadata.versionInfo.revision')" />
          </th>
          <th>
            <xsl:value-of select="i18n:translate('metadata.versionInfo.action')" />
          </th>
          <th>
            <xsl:value-of select="i18n:translate('metadata.versionInfo.date')" />
          </th>
          <th>
            <xsl:value-of select="i18n:translate('metadata.versionInfo.user')" />
          </th>
        </tr>
        <xsl:for-each select="$verinfo/versions/version">
          <xsl:sort order="descending" select="position()" data-type="number" />
          <tr>
            <td class="ver">
              <xsl:number level="single" format="1." />
            </td>
            <td class="rev">
              <xsl:if test="@r">
                <xsl:variable name="href">
                  <xsl:call-template name="UrlSetParam">
                    <xsl:with-param name="url" select="concat($WebApplicationBaseURL,'receive/',$ID)" />
                    <xsl:with-param name="par" select="'r'" />
                    <xsl:with-param name="value" select="@r" />
                  </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="@action='D'">
                    <xsl:value-of select="@r" />
                  </xsl:when>
                  <xsl:otherwise>
                    <a href="{$href}">
                      <xsl:value-of select="@r" />
                    </a>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
            </td>
            <td class="action">
              <xsl:if test="@action">
                <xsl:value-of select="i18n:translate(concat('metaData.versions.action.',@action))" />
              </xsl:if>
            </td>
            <td class="@date">
              <xsl:call-template name="formatISODate">
                <xsl:with-param name="date" select="@date" />
                <xsl:with-param name="format" select="i18n:translate('metaData.dateTime')" />
              </xsl:call-template>
            </td>
            <td class="user">
              <xsl:if test="@user">
                <xsl:value-of select="@user" />
              </xsl:if>
            </td>
          </tr>
        </xsl:for-each>
      </table>
    </div>
    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>