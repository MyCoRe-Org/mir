<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:mcrurn="xalan://org.mycore.urn.MCRXMLFunctions" exclude-result-prefixes="i18n mcr mods acl xlink mcrurn"
>
  <xsl:import href="xslImport:modsmeta:metadata/mir-collapse-files.xsl" />
  <xsl:param name="MCR.URN.Resolver.MasterURL" select="''" />
  <xsl:template match="/">

    <xsl:choose>
      <xsl:when test="key('rights', mycoreobject/@ID)/@read or key('rights', mycoreobject/structure/derobjects/derobject/@xlink:href)/@accKeyEnabled">

        <xsl:variable name="objID" select="mycoreobject/@ID" />
        <div id="mir-collapse-files">
          <xsl:for-each select="mycoreobject/structure/derobjects/derobject[key('rights', @xlink:href)/@read or key('rights', @xlink:href)/@readKey or key('rights', @xlink:href)/@writeKey]">
            <!-- TODO: MIR-339 potentially slow: we should use ajax here -->
            <xsl:variable name="derId" select="@xlink:href" />
            <xsl:variable name="derivateXML" select="document(concat('mcrobject:',$derId))" />
            <xsl:variable name="derivateWithURN" select="mcrurn:hasURNDefined($derId)" />

            <div id="files{@xlink:href}" class="file_box">
              <div class="row header">
                <div class="col-xs-12">
                  <div class="headline">
                    <div class="title">
                      <a class="btn btn-primary btn-sm file_toggle" data-toggle="collapse" href="#collapse{@xlink:href}" aria-expanded="false" aria-controls="collapse{@xlink:href}">
                        <span>
                          <xsl:choose>
                            <xsl:when test="$derivateXML//titles/title[@xml:lang=$CurrentLang]">
                              <xsl:value-of select="$derivateXML//titles/title[@xml:lang=$CurrentLang]" />
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="i18n:translate('metadata.files.file')" />
                            </xsl:otherwise>
                          </xsl:choose>
                        </span>
                        <xsl:if test="position() > 1">
                          <span class="set_number">
                            <xsl:value-of select="position()" />
                          </span>
                        </xsl:if>
                        <span class="caret"></span>
                      </a>

                      <xsl:if test="$derivateWithURN=true()">
                        <xsl:variable name="derivateURN" select="$derivateXML/mycorederivate/derivate/fileset/@urn" />
                        <sup class="file_urn">
                          <a href="{$MCR.URN.Resolver.MasterURL}{$derivateURN}" title="{$derivateURN}">
                            URN
                          </a>
                        </sup>
                      </xsl:if>
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

                <xsl:choose>
                  <xsl:when test="key('rights', @xlink:href)/@read">

                    <xsl:variable name="ifsDirectory" select="document(concat('ifs:',$derId,'/'))" />
                    <xsl:variable name="numOfFiles" select="count($ifsDirectory/mcr_directory/children/child)" />
                    <xsl:variable name="maindoc" select="$derivateXML/mycorederivate/derivate/internals/internal/@maindoc" />
                    <xsl:variable name="path" select="$ifsDirectory/mcr_directory/path" />

                    <xsl:for-each select="$ifsDirectory/mcr_directory/children/child">
                      <xsl:variable name="fileNameExt" select="concat($path,./name)" />
                      <xsl:variable name="urn" select="$derivateXML/mycorederivate/derivate/fileset/file[@name=$fileNameExt]/urn" />
                      <xsl:apply-templates select="." >
                        <xsl:with-param name="derId"><xsl:value-of select="$derId" /></xsl:with-param>
                        <xsl:with-param name="objID"><xsl:value-of select="$objID" /></xsl:with-param>
                        <xsl:with-param name="derivateWithURN"><xsl:value-of select="$derivateWithURN" /></xsl:with-param>
                        <xsl:with-param name="maindoc"><xsl:value-of select="$maindoc" /></xsl:with-param>
                        <xsl:with-param name="urn"><xsl:value-of select="$urn" /></xsl:with-param>
                      </xsl:apply-templates>
                    </xsl:for-each>

                  </xsl:when>
                  <xsl:otherwise>
                    <div class="col-xs-12">
                      <xsl:value-of select="i18n:translate('mir.derivate.no_access')" />
                    </div>
                  </xsl:otherwise>
                </xsl:choose>

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

  <xsl:template match="child[@type='directory']" >
    <xsl:param name="derId" />
    <xsl:param name="objID" />
    <xsl:param name="derivateWithURN" />
    <xsl:param name="maindoc" />
    <xsl:param name="urn" />

    <xsl:apply-templates select="." mode="childWriter">
      <xsl:with-param name="derId"><xsl:value-of select="$derId" /></xsl:with-param>
      <xsl:with-param name="objID"><xsl:value-of select="$objID" /></xsl:with-param>
      <xsl:with-param name="derivateWithURN"><xsl:value-of select="$derivateWithURN" /></xsl:with-param>
      <xsl:with-param name="maindoc"><xsl:value-of select="$maindoc" /></xsl:with-param>
      <xsl:with-param name="urn"><xsl:value-of select="$urn" /></xsl:with-param>
    </xsl:apply-templates>

    <xsl:variable name="dirName" select="./name" />
    <xsl:variable name="directory" select="document(concat('ifs:',$derId,'/',mcr:encodeURIPath($dirName)))" />
    <xsl:for-each select="$directory/mcr_directory/children/child">
      <xsl:apply-templates select="." mode="childWriter">
        <xsl:with-param name="derId"><xsl:value-of select="$derId" /></xsl:with-param>
        <xsl:with-param name="objID"><xsl:value-of select="$objID" /></xsl:with-param>
        <xsl:with-param name="derivateWithURN"><xsl:value-of select="$derivateWithURN" /></xsl:with-param>
        <xsl:with-param name="maindoc"><xsl:value-of select="$maindoc" /></xsl:with-param>
        <xsl:with-param name="urn"><xsl:value-of select="$urn" /></xsl:with-param>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="child[@type='file']">
    <xsl:param name="derId" />
    <xsl:param name="objID" />
    <xsl:param name="derivateWithURN" />
    <xsl:param name="maindoc" />
    <xsl:param name="urn" />

    <xsl:apply-templates select="." mode="childWriter">
      <xsl:with-param name="derId"><xsl:value-of select="$derId" /></xsl:with-param>
      <xsl:with-param name="objID"><xsl:value-of select="$objID" /></xsl:with-param>
      <xsl:with-param name="derivateWithURN"><xsl:value-of select="$derivateWithURN" /></xsl:with-param>
      <xsl:with-param name="maindoc"><xsl:value-of select="$maindoc" /></xsl:with-param>
      <xsl:with-param name="urn"><xsl:value-of select="$urn" /></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="child" mode="childWriter">
    <xsl:param name="derId" />
    <xsl:param name="objID" />
    <xsl:param name="derivateWithURN" />
    <xsl:param name="maindoc" />
    <xsl:param name="urn" />

    <xsl:variable name="path" select="../../path" />
    <xsl:variable name="fileName" >
      <xsl:choose>
        <xsl:when test="$path != '/' and $path != ''">
          <xsl:value-of select="substring(concat($path,./name),2)" ></xsl:value-of>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="./name" ></xsl:value-of>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="filePath" select="concat($derId,'/',mcr:encodeURIPath($fileName),$HttpSession)" />
    <xsl:variable name="fileCss">
      <xsl:choose>
        <xsl:when test="$maindoc = $fileName">
          <xsl:text>active_file</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>file</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div class="col-xs-12">
      <div class="file_set {$fileCss}">
        <xsl:if test="(acl:checkPermission($derId,'writedb') or acl:checkPermission($derId,'deletedb')) and $derivateWithURN='false'">
          <div class="options pull-right">
            <div class="btn-group">
              <a href="#" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                <i class="fa fa-cog"></i>
                <span class="caret"></span>
              </a>
              <ul class="dropdown-menu dropdown-menu-right">
                <xsl:if test="acl:checkPermission($derId,'writedb') and @type!='directory'">
                  <li>
                    <a title="{i18n:translate('IFS.mainFile')}"
                      href="{$WebApplicationBaseURL}servlets/MCRDerivateServlet{$HttpSession}?derivateid={$derId}&amp;objectid={$objID}&amp;todo=ssetfile&amp;file={$fileName}"
                      class="option" >
                      <span class="glyphicon glyphicon-star"></span>
                      <xsl:value-of select="i18n:translate('IFS.mainFile')" />
                    </a>
                  </li>
                </xsl:if>
                <xsl:if test="acl:checkPermission($derId,'deletedb')">
                  <li>
                    <a href="{$WebApplicationBaseURL}servlets/MCRDerivateServlet{$HttpSession}?derivateid={$derId}&amp;objectid={$objID}&amp;todo=sdelfile&amp;file={$fileName}"
                      class="option confirm_deletion">
                      <xsl:attribute name="data-text">
                        <xsl:value-of select="i18n:translate(concat('mir.confirm.',@type,'.text'))" />
                      </xsl:attribute>
                      <xsl:attribute name="title">
                        <xsl:value-of select="i18n:translate(concat('IFS.',@type,'Delete'))" />
                      </xsl:attribute>
                      <span class="glyphicon glyphicon-trash"></span>
                      <xsl:value-of select="i18n:translate(concat('IFS.',@type,'Delete'))" />
                    </a>
                  </li>
                </xsl:if>
              </ul>
            </div>
          </div>
        </xsl:if>
        <span class="file_size">
          <xsl:text>[ </xsl:text>
          <xsl:call-template name="formatFileSize">
            <xsl:with-param name="size" select="size" />
          </xsl:call-template>
          <xsl:text> ]</xsl:text>
        </span>
        <span class="{$fileCss} glyphicon glyphicon-star">
        </span>
        <span class="file_date">
          <xsl:call-template name="formatISODate">
            <xsl:with-param name="date" select="date[@type='lastModified']" />
            <xsl:with-param name="format" select="i18n:translate('metaData.date')" />
          </xsl:call-template>
        </span>
        <span class="file_preview">
          <img src="{$WebApplicationBaseURL}images/icons/icon_common_disabled.png" alt="">
            <xsl:if test="'.pdf' = translate(substring($fileName, string-length($fileName) - 3),'PDF','pdf')">
              <xsl:attribute name="data-toggle">tooltip</xsl:attribute>
              <xsl:attribute name="data-placement">top</xsl:attribute>
              <xsl:attribute name="data-html">true</xsl:attribute>
              <xsl:attribute name="data-title">
                  <xsl:text>&lt;img src="</xsl:text>
                  <xsl:value-of select="concat($WebApplicationBaseURL,'img/pdfthumb/',$filePath,'?centerThumb=no')" />
                  <xsl:text>"&gt;</xsl:text>
                </xsl:attribute>
              <xsl:message>
                PDF
              </xsl:message>
            </xsl:if>
          </img>
        </span>
        <span class="file_name">
          <xsl:choose>
            <xsl:when test="@type!='directory'" >
             <a>
               <xsl:attribute name="href" >
                 <xsl:value-of select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$filePath)" />
               </xsl:attribute>
               <xsl:value-of select="$fileName" />
             </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$fileName" />
            </xsl:otherwise>
          </xsl:choose>
        </span>
        <xsl:if test="string-length($urn)>0">
          <sup class="file_urn">
            <a href="{$MCR.URN.Resolver.MasterURL}{$urn}" title="{$urn}">
              URN
            </a>
          </sup>
        </xsl:if>
      </div>
    </div>
  </xsl:template>
</xsl:stylesheet>