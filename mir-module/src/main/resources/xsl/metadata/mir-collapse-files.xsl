<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="i18n mcr mods xlink">
  <xsl:import href="xslImport:modsmeta:metadata/mir-collapse-files.xsl" />
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="key('rights', mycoreobject/@ID)/@view">
        <div id="mir-collapse-files">
          <xsl:for-each select="mycoreobject/structure/derobjects/derobject[key('rights', @xlink:href)/@read]">
            <div class="panel panel-default" id="files{@xlink:href}">
              <div class="panel-heading">
                <h4 class="panel-title">
                  <a data-toggle="collapse" href="#collapse{@xlink:href}">
                    Files
                    <span class="caret"></span>
                  </a>
                </h4>
              </div>
              <div id="collapse{@xlink:href}" class="panel-collapse collapse in">
                <div class="panel-body" style="margin:0;padding:0;">
                  <xsl:variable name="derId" select="@xlink:href" />
                  <xsl:variable name="ifsDirectory" select="document(concat('ifs:',@xlink:href,'/'))" />
                  <table class="table table-striped">
                    <thead>
                      <tr class="">
                        <th>Name</th>
                        <th>Date</th>
                        <th>Size</th>
                        <th></th>
                      </tr>
                    </thead>
                    <tbody>
                      <xsl:for-each select="$ifsDirectory/mcr_directory/children/child">
                        <tr>
                          <td>
                            <a href="{$ServletsBaseURL}MCRFileNodeServlet/{$derId}/{mcr:encodeURIPath(name)}{$HttpSession}">
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