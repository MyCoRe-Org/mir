<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="i18n mcr mods xlink">
  <xsl:import href="xslImport:modsmeta:metadata/mir-collapse-files.xsl" />
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="key('rights', mycoreobject/@ID)/@view">
        <xsl:variable name="objID" select="mycoreobject/@ID" />
        <div id="mir-collapse-files">
          <xsl:for-each select="mycoreobject/structure/derobjects/derobject[key('rights', @xlink:href)/@read]">
            <div class="panel panel-default" id="files{@xlink:href}">
              <div class="panel-heading">
                <h4 class="panel-title">
                  <a data-toggle="collapse" href="#collapse{@xlink:href}">
                    <xsl:value-of select="i18n:translate('metadata.files.file')" />
                    <span class="caret"></span>
                  </a>
                  <xsl:apply-templates select="." mode="derivateActions">
                    <xsl:with-param name="deriv" select="@xlink:href" />
                    <xsl:with-param name="parentObjID" select="$objID" />
                  </xsl:apply-templates>
                </h4>
              </div>
              <div id="collapse{@xlink:href}" class="panel-collapse collapse in">
                <div class="panel-body" style="margin:0;padding:0;">
                  <xsl:variable name="derId" select="@xlink:href" />
                  <xsl:variable name="ifsDirectory" select="document(concat('ifs:',@xlink:href,'/'))" />
                  <table class="table table-striped">
                    <thead>
                      <tr class="">
                        <th><xsl:value-of select="i18n:translate('metadata.files.name')" /></th>
                        <th><xsl:value-of select="i18n:translate('metadata.files.date')" /></th>
                        <th><xsl:value-of select="i18n:translate('metadata.files.size')" /></th>
                      </tr>
                    </thead>
                    <tbody>
                      <xsl:for-each select="$ifsDirectory/mcr_directory/children/child">
                        <tr>
                          <td>
                            <xsl:variable name="filePath" select="concat($derId,'/',mcr:encodeURIPath(name),$HttpSession)" />
                            <a href="{$ServletsBaseURL}MCRFileNodeServlet/{$filePath}">
                              <xsl:if test="'.pdf' = translate(substring(name, string-length(name) - 3),'PDF','pdf')">
                                <xsl:attribute name="data-toggle">tooltip</xsl:attribute>
                                <xsl:attribute name="data-placement">top</xsl:attribute>
                                <xsl:attribute name="data-html">true</xsl:attribute>
                                <xsl:attribute name="data-title">
                                  <xsl:text>&lt;img src="</xsl:text>
                                  <xsl:value-of select="concat($WebApplicationBaseURL,'img/pdfthumb/',$filePath,'?centerThumb=no')"/>
                                  <xsl:text>"&gt;</xsl:text>
                                </xsl:attribute>
                                <xsl:message>
                                  PDF
                                </xsl:message>
                              </xsl:if>
                              <xsl:value-of select="name" />
                            </a>
                          </td>
                          <td>
                            <xsl:value-of select="date[@type='lastModified']" />
                          </td>
                          <td>
                            <xsl:call-template name="formatFileSize">
                              <xsl:with-param name="size" select="size" />
                            </xsl:call-template>
                          </td>
                        </tr>
                      </xsl:for-each>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </xsl:for-each>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:comment>
          <xsl:value-of select="'mir-collapse-files: no &quot;view&quot; permission'" />
        </xsl:comment>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>