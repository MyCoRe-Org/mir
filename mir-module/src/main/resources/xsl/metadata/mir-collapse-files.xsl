<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager" exclude-result-prefixes="i18n mcr mods acl xlink">
  <xsl:import href="xslImport:modsmeta:metadata/mir-collapse-files.xsl" />
  <xsl:template match="/">

    <xsl:choose>
      <xsl:when test="key('rights', mycoreobject/@ID)/@view">
        <xsl:variable name="objID" select="mycoreobject/@ID" />
        <div id="mir-collapse-files">
          <xsl:for-each select="mycoreobject/structure/derobjects/derobject[key('rights', @xlink:href)/@read]">
            <div id="files{@xlink:href}" class="file_box">
              <div class="row header">
                <div class="col-xs-12">
                  <div class="headline">
                    <div class="title">
                      <a data-toggle="collapse" href="#collapse{@xlink:href}">
                        <span><xsl:value-of select="i18n:translate('metadata.files.file')" /></span>
                        <span class="caret"></span>
                      </a>
                    </div>
                    <xsl:apply-templates select="." mode="derivateActions">
                      <xsl:with-param name="deriv" select="@xlink:href" />
                      <xsl:with-param name="parentObjID" select="$objID" />
                    </xsl:apply-templates>
                    <div class="clearfix" />
                  </div>
                </div>
              </div>
              <div id="collapse{@xlink:href}" class="row body collapse in">

                  <xsl:variable name="derId" select="@xlink:href" />
                  <xsl:variable name="ifsDirectory" select="document(concat('ifs:',@xlink:href,'/'))" />
                  <xsl:variable name="derivateXML" select="document(concat('mcrobject:',@xlink:href))" />
                  <xsl:variable name="derivateURN" select="$derivateXML/mycorederivate/derivate/fileset/@urn" />
                  <xsl:variable name="numOfFiles"  select="count($ifsDirectory/mcr_directory/children/child)" />
                  <xsl:variable name="maindoc"     select="$derivateXML/mycorederivate/derivate/internals/internal/@maindoc" />
                  <xsl:variable name="path"        select="count($ifsDirectory/mcr_directory/path)" />

                  <xsl:for-each select="$ifsDirectory/mcr_directory/children/child">
                    <xsl:variable name="filePath" select="concat($derId,'/',mcr:encodeURIPath(name),$HttpSession)" />
                    <xsl:variable name="urn" select="$derivateXML/mycorederivate/derivate/fileset/file[@name=./name]/urn/text()" />
                    <xsl:variable name="fileCss">
                      <xsl:choose>
                        <xsl:when test="$numOfFiles = 1">
                          <xsl:text>file</xsl:text>
                        </xsl:when>
                        <xsl:when test="$maindoc = name">
                          <xsl:text>active_file</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:text>file</xsl:text>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>

                    <div class="col-xs-12">
                      <div class="file_set {$fileCss}">
                        <div class="options pull-right">
                          <div class="btn-group">
                            <a href="#" class="btn btn-default dropdown-toggle" data-toggle="dropdown"><i class="fa fa-cog"></i> <span class="caret"></span></a>
                            <ul class="dropdown-menu dropdown-menu-right">
                              <xsl:if test="acl:checkPermission($derId,'writedb') or mcr:isCurrentUserInRole('admin')">
                                <li>
                                  <xsl:variable name="fileName" select="./name" />
                                  <a title="{i18n:translate('IFS.mainFile')}"
                                     href="{$WebApplicationBaseURL}servlets/MCRDerivateServlet{$HttpSession}?derivateid={$derId}&amp;objectid={$objID}&amp;todo=ssetfile&amp;file={$fileName}"
                                     class="option what_ever">
                                    <span class="glyphicon glyphicon-star"></span>
                                    <xsl:value-of select="i18n:translate('IFS.mainFile')" />
                                  </a>
                                </li>
                              </xsl:if>
                              <xsl:if test="acl:checkPermission($derId,'deletedb') or mcr:isCurrentUserInRole('admin')">
                                <li>
                                  <xsl:variable name="fileName" select="./name" />
                                  <a title="{i18n:translate('IFS.fileDelete')}"
                                     href="{$WebApplicationBaseURL}servlets/MCRDerivateServlet{$HttpSession}?derivateid={$derId}&amp;objectid={$objID}&amp;todo=sdelfile&amp;file={$fileName}"
                                     class="option what_ever"><span class="glyphicon glyphicon-trash"></span><xsl:value-of select="i18n:translate('IFS.fileDelete')" /></a>
                                </li>
                              </xsl:if>
                            </ul>
                          </div>
                        </div>
                        <span class="file_size">[
                          <xsl:call-template name="formatFileSize">
                            <xsl:with-param name="size" select="size" />
                          </xsl:call-template>
                        ]</span>
                        <span class="{$fileCss} glyphicon glyphicon-star"> </span>
                        <span class="file_date">
                          <xsl:call-template name="formatISODate">
                            <xsl:with-param name="date" select="date[@type='lastModified']" />
                            <xsl:with-param name="format" select="i18n:translate('metaData.date')" />
                          </xsl:call-template>
                        </span>
                        <span class="file_preview">
                          <img src="/mir/mir-flatmir-layout/images/mycore_logo_small_invert.png" alt="">
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
                          </img>
                        </span>
                        <span class="file_name">
                          <a href="{$ServletsBaseURL}MCRFileNodeServlet/{$filePath}">
                            <xsl:value-of select="name" />
                          </a>
                        </span>
                        <xsl:if test="string-length($urn)>0">
                          <sup class="file_urn">
                            <a href="{concat('http://nbn-resolving.de/urn/resolver.pl?urn=',$derivateURN)}"
                               title="{$urn}">
                               URN
                            </a>
                          </sup>
                        </xsl:if>
                      </div>
                    </div>
                  </xsl:for-each>
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