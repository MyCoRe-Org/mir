<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY html-output SYSTEM "xsl/xsl-output-html.fragment">
]>
<!-- ============================================== -->
<!-- $Revision: 1.7 $ $Date: 2006-09-06 12:20:05 $ -->
<!-- ============================================== -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:mcrurn="xalan://org.mycore.urn.MCRXMLFunctions" exclude-result-prefixes="xlink mcr i18n mcrurn">
    &html-output;
  <xsl:param name="MCR.URN.Display.DFG.Viewer.URN" />
  <xsl:param name="MCR.Mets.Filename" />

  <xsl:variable name="PageTitle" select="'Die Detailliste des Objektes'" />
  <xsl:include href="MyCoReLayout.xsl" />
  <!-- include custom templates for supported objecttypes -->
  <xsl:include href="xslInclude:objectTypes" />

  <xsl:template match="/mcr_directory">
    <xsl:comment>
      Start /mcr_directory (mcr_directory.xsl)
    </xsl:comment>
    <xsl:variable name="derivlink" select="concat('mcrobject:',ownerID)" />
    <xsl:variable name="derivdoc" select="document($derivlink)" />
    <xsl:variable name="sourcelink" select="concat('mcrobject:',$derivdoc/mycorederivate/derivate/linkmetas/linkmeta/@xlink:href)" />
    <xsl:variable name="sourcedoc" select="document($sourcelink)" />
    <xsl:variable name="accesseditvalue">
      <xsl:choose>
        <!-- if source object and derivate allows writing -->
        <xsl:when
          test="acl:checkPermission($derivdoc/mycorederivate/derivate/linkmetas/linkmeta/@xlink:href,'writedb') and acl:checkPermission(ownerID,'writedb')">
          <xsl:value-of select="'true'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'false'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="accessdeletevalue">
      <xsl:choose>
        <!-- admins always -->
        <xsl:when test="mcr:isCurrentUserInRole('admin')">
          <xsl:value-of select="'true'" />
        </xsl:when>
        <!-- do not allow delete if urn -->
        <xsl:when test="$derivdoc/mycorederivate/fileset/@urn">
          <xsl:value-of select="'false'" />
        </xsl:when>
        <!-- if source object and derivate allows deleting -->
        <xsl:when
          test="acl:checkPermission($derivdoc/mycorederivate/derivate/linkmetas/linkmeta/@xlink:href,'deletedb') and acl:checkPermission(ownerID,'deletedb')">
          <xsl:value-of select="'true'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'false'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="maindoc" select="$derivdoc/mycorederivate/derivate/internals/internal/@maindoc" />

    <!-- check the access rights -->
    <table id="metaData" cellpadding="0" cellspacing="0">
      <tr>
        <th class="metahead" colspan="2">
          <xsl:value-of select="i18n:translate('IFS.commonData')" />
        </th>
      </tr>
      <tr>
        <td class="metaname">
          <xsl:value-of select="concat(i18n:translate('IFS.id'),' :')" />
        </td>
        <td class="metavalue">
          <xsl:value-of select="$derivdoc/mycorederivate/@ID" />
        </td>
      </tr>
      <tr>
        <td class="metaname">
          <xsl:value-of select="concat(i18n:translate('IFS.size'),' :')" />
        </td>
        <td class="metavalue">
          <xsl:value-of select="concat(size,' ',i18n:translate('IFS.bytes'))" />
        </td>
      </tr>
      <tr>
        <td class="metaname">
          <xsl:value-of select="concat(i18n:translate('IFS.total'),' :')" />
        </td>
        <td class="metavalue">
          <xsl:value-of select="concat( numChildren/total/files, ' / ', numChildren/total/directories )" />
        </td>
      </tr>
      <tr>
        <td class="metaname">
          <xsl:value-of select="concat(i18n:translate('IFS.startFile'),' :')" />
        </td>
        <td class="metavalue">
          <xsl:variable name="derivifs"
            select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derivdoc/mycorederivate/@ID,'/',mcr:encodeURIPath($maindoc),$HttpSession)" />
          <a href="{$derivifs}" target="_blank">
            <xsl:value-of select="$maindoc" />
          </a>
        </td>
      </tr>
      <tr>
        <td class="metaname">
          <xsl:value-of select="concat(i18n:translate('metaData.lastChanged'),' :')" />
        </td>
        <td class="metavalue">
          <xsl:value-of select="date" />
        </td>
      </tr>
      <tr>
        <td class="metaname">
          <xsl:value-of select="concat(i18n:translate('IFS.docTitle'),' :')" />
        </td>
        <td class="metavalue">
          <xsl:call-template name="objectLink">
            <xsl:with-param name="obj_id" select="$sourcedoc/mycoreobject/@ID" />
          </xsl:call-template>
        </td>
      </tr>
      <tr>
        <td class="metaname">
          <xsl:value-of select="concat(i18n:translate('IFS.download'),' (zip)',' :')" />
        </td>
        <td class="metavalue">
          <a href="{concat($ServletsBaseURL, 'MCRZipServlet/', $derivdoc/mycorederivate/@ID,$HttpSession)}" title="{i18n:translate('IFS.download')}">
            <xsl:value-of select="concat(i18n:translate('IFS.download.userMsg'), ' (', mcr:getSize($derivdoc/mycorederivate/@ID) ,')')" />
          </a>
        </td>
      </tr>
      <tr>
        <td class="metaname">
          <xsl:value-of select="concat(i18n:translate('IFS.download'),' (tar)',' :')" />
        </td>
        <td class="metavalue">
          <a href="{concat($ServletsBaseURL, 'MCRTarServlet/', $derivdoc/mycorederivate/@ID,$HttpSession)}" title="{i18n:translate('IFS.download')}">
            <xsl:value-of select="concat(i18n:translate('IFS.download.userMsg'), ' (', mcr:getSize($derivdoc/mycorederivate/@ID) ,')')" />
          </a>
        </td>
      </tr>

      <xsl:if test="$MCR.URN.Display.DFG.Viewer.URN and $derivdoc/mycorederivate/derivate/fileset/@urn">
        <tr>
          <td class="metaname">
            <xsl:value-of select="concat(i18n:translate('derivate.urn.dfg-viewer'),' :')" />
          </td>
          <td class="metavalue">
            <xsl:variable name="dfgViewerURN" select="mcr:createAlternativeURN($derivdoc/mycorederivate/derivate/fileset/@urn, 'dfg')" />
            <a href="{concat('http://nbn-resolving.de/urn/resolver.pl?urn=', $dfgViewerURN)}" title="{i18n:translate('derivate.urn.dfg-viewer')}">
              <xsl:value-of select="$dfgViewerURN" />
            </a>
          </td>
        </tr>
      </xsl:if>

    </table>
    <table id="files" cellpadding="0" cellspacing="0">
      <tr>
        <th class="metahead"></th>
        <th class="metahead">
          <xsl:value-of select="i18n:translate('IFS.fileName')" />
        </th>
        <th class="metahead">
          <xsl:value-of select="i18n:translate('IFS.fileSize')" />
        </th>
        <th class="metahead">
          <xsl:value-of select="i18n:translate('IFS.fileType')" />
        </th>
        <th class="metahead">
          <xsl:value-of select="i18n:translate('metaData.lastChanged')" />
        </th>
        <th class="metahead"></th>
      </tr>
      <xsl:apply-templates select="path" />
      <xsl:apply-templates select="children">
        <xsl:with-param name="accesseditvalue" select="$accesseditvalue" />
        <xsl:with-param name="accessdeletevalue" select="$accessdeletevalue" />
        <xsl:with-param name="maindoc" select="$derivdoc/mycorederivate/derivate/internals/internal/@maindoc" />
        <xsl:with-param name="fileset" select="$derivdoc/mycorederivate/derivate/fileset" />
        <xsl:with-param name="se_mcrid" select="$derivdoc/mycorederivate/@ID" />
        <xsl:with-param name="re_mcrid" select="$sourcedoc/mycoreobject/@ID" />
      </xsl:apply-templates>
    </table>
    <hr />
    <xsl:comment>
      End /mcr_directory (mcr_directory.xsl)
    </xsl:comment>
  </xsl:template>

  <!-- parent directory ********************************************** -->
  <xsl:template match="path">
    <xsl:if test="contains(.,'/')">
      <xsl:variable name="parent">
        <xsl:call-template name="parent">
          <xsl:with-param name="path" select="." />
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="parentdoc" select="document(concat('ifs:',$parent))" />
      <xsl:variable name="derivifs" select="concat($ServletsBaseURL,'MCRFileNodeServlet/',mcr:encodeURIPath($parent),$HttpSession)" />
      <tr>
        <td class="metavalue"></td>
        <td class="metavalue">
          <a href="{$derivifs}">..</a>
        </td>
        <td class="metavalue">
          <xsl:value-of select="$parentdoc/mcr_directory/size" />
          <xsl:value-of select="concat(i18n:translate('IFS.bytes'),' :')" />
        </td>
        <td class="metavalue">
          <xsl:value-of select="i18n:translate('IFS.directory')" />
        </td>
        <td class="metavalue">
          <xsl:value-of select="$parentdoc/mcr_directory/date[@type='lastModified']" />
        </td>
        <td class="metavalue"></td>
      </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template name="parent">
    <xsl:param name="path" />
    <xsl:param name="position" select="string-length($path)-1" />
    <xsl:choose>
      <xsl:when test="contains(substring($path,$position),'/')">
        <!--found the last element -->
        <xsl:choose>
          <!-- Workaround for FilenodeServlet-Bug: trailing slashes MUST be ommited for directory but are REQUIRED if at Level of OwnerID -->
          <xsl:when test="contains(substring($path,0,$position),'/')">
            <xsl:value-of select="substring($path,0,$position)" />
          </xsl:when>
          <xsl:otherwise>
            <!-- return ownerID with trailing '/' -->
            <xsl:value-of select="concat(substring($path,0,$position),'/')" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="parent">
          <xsl:with-param name="path" select="$path" />
          <xsl:with-param name="position" select="$position - 1" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Child componets ********************************************** -->
  <xsl:template match="children">
    <xsl:param name="accesseditvalue" />
    <xsl:param name="accessdeletevalue" />
    <xsl:param name="fileset" />
    <xsl:param name="maindoc" />
    <xsl:param name="se_mcrid" />
    <xsl:param name="re_mcrid" />
    <xsl:variable name="type" select="substring-before(substring-after($re_mcrid,'_'),'_')" />
    <xsl:variable name="allfiles" select="../numChildren/total/files" />
    <xsl:variable name="path" select="substring-after(../path,../ownerID)" />
    <xsl:variable name="contentTypes" select="document('webapp:FileContentTypes.xml')" />
    <xsl:for-each select="child">
      <xsl:sort select="@type" />
      <xsl:sort select="contentType" />
      <xsl:sort select="name" />

      <xsl:variable name="rowStyle">
        <xsl:choose>
          <xsl:when test="position() mod 2 = 0">
            <xsl:value-of select="'derivateFileListEven'" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'derivateFileListOdd'" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="derivid" select="../../path" />
      <xsl:variable name="derivmain" select="name" />
      <xsl:variable name="currentFileID" select="./@ID" />

      <xsl:variable name="urn" select="$fileset/file[@name=concat($path, '/', $derivmain)]/urn/text()" />
      <xsl:variable name="handle" select="$fileset/file[@name=concat($path, '/', $derivmain)]/handle/text()" />

      <tr class="{$rowStyle}">
        <td>
          <xsl:choose>
            <xsl:when test="$maindoc = name">
              <img src="{$WebApplicationBaseURL}images/button_green.gif" alt="{i18n:translate('IFS.mainFile')}" border="0" />
            </xsl:when>
            <xsl:when test="concat('/',$maindoc) = concat($path,'/',name)">
              <img src="{$WebApplicationBaseURL}images/button_green.gif" alt="{i18n:translate('IFS.mainFile')}" border="0" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="$accesseditvalue = 'true' and @type = 'file'">
                <form action="{$WebApplicationBaseURL}servlets/MCRDerivateServlet{$HttpSession}" method="get">
                  <input name="lang" type="hidden" value="{$CurrentLang}" />
                  <input name="derivateid" type="hidden">
                    <xsl:attribute name="value">
                      <xsl:value-of select="$se_mcrid" />
                    </xsl:attribute>
                  </input>
                  <input name="objectid" type="hidden">
                    <xsl:attribute name="value">
                      <xsl:value-of select="$re_mcrid" />
                    </xsl:attribute>
                  </input>
                  <input name="todo" type="hidden" value="ssetfile" />
                  <input name="file" type="hidden">
                    <xsl:attribute name="value">
                      <xsl:value-of select="substring-after(concat($path,'/',name),'/')" />
                    </xsl:attribute>
                  </input>
                  <input type="image" src="{$WebApplicationBaseURL}images/button_light.gif" title="{i18n:translate('IFS.mainFile')}"
                    border="0" />
                </form>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td>
          <xsl:variable name="filename">
            <xsl:choose>
              <xsl:when test="(string-length($derivmain) &lt; 30)">
                <xsl:value-of select="translate($derivmain,'@','')" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="translate(substring($derivmain ,0,25),'@','')" />
                <xsl:value-of select="' [...]'" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:if test="@type = 'directory'">
            <xsl:variable name="derivifs"
              select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derivid,'/',mcr:encodeURIPath($derivmain),$HttpSession)" />
            <a title="{$derivmain}">
              <xsl:attribute name="href">
                <xsl:value-of select="$derivifs" />
              </xsl:attribute>
              <name>
                <xsl:value-of select="$filename" />
              </name>
            </a>
          </xsl:if>
          <xsl:if test="@type = 'file'">
            <xsl:variable name="derivifs"
              select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derivid,'/',mcr:encodeURIPath($derivmain),$HttpSession)" />
            <xsl:variable name="toolTipImg"
              select="concat($ServletsBaseURL,'MCRThumbnailServlet/',$derivid,'/',mcr:encodeURIPath($derivmain),$HttpSession)" />
            <a data-toggle="popover" data-html="true" data-content="&lt;img src='{$toolTipImg}' /&gt;" data-trigger="hover"
              data-placement="right" title="{$derivmain}" target="_blank">
              <xsl:attribute name="href">
                <xsl:value-of select="$derivifs" />
              </xsl:attribute>
              <name>
                <xsl:value-of select="$filename" />
              </name>
            </a>
          </xsl:if>
        </td>
        <td>
          <xsl:value-of select="concat(size,' ',i18n:translate('IFS.bytes'))" />
        </td>
        <xsl:if test="@type = 'directory'">
          <td class="metavalue">
            <xsl:value-of select="i18n:translate('IFS.directory')" />
          </td>
        </xsl:if>
        <xsl:if test="@type = 'file'">
          <xsl:variable name="ctype" select="contentType" />
          <td>
            <xsl:value-of select="$contentTypes/FileContentTypes/type/label[../@ID=$ctype]" />
          </td>
        </xsl:if>
        <td>
          <xsl:value-of select="date" />
        </td>
        <td>
          <xsl:if test="$accessdeletevalue = 'true'">
            <form action="{$WebApplicationBaseURL}servlets/MCRDerivateServlet{$HttpSession}" method="get">
              <input name="lang" type="hidden" value="{$CurrentLang}" />
              <input name="derivateid" type="hidden">
                <xsl:attribute name="value">
                  <xsl:value-of select="$se_mcrid" />
                </xsl:attribute>
              </input>
              <input name="objectid" type="hidden">
                <xsl:attribute name="value">
                  <xsl:value-of select="$re_mcrid" />
                </xsl:attribute>
              </input>
              <input name="todo" type="hidden" value="sdelfile" />
              <input name="file" type="hidden">
                <xsl:attribute name="value">
                  <xsl:value-of select="substring-after(concat($path,'/',name),'/')" />
                </xsl:attribute>
              </input>
              <input class="inputDeleteFile" type="image" alt=" " title="{i18n:translate('IFS.fileDelete')}" border="0" />
            </form>
          </xsl:if>
        </td>
        <td>
          <xsl:if
            test="mcrurn:hasURNDefined($derivid) and string-length($urn) &lt; 1 and $accesseditvalue = 'true' and @type = 'file' and not(name = $MCR.Mets.Filename)">
            <a title="{i18n:translate('common.metaData.document.addURN')}"
              href="{concat($ServletsBaseURL,'MCRAddURNToObjectServlet',$HttpSession, '?object=', $derivid,'&amp;target=file&amp;fileId=', $currentFileID,'&amp;path=', concat($path,'/',name))}">
              <img class="inputAddUrn" alt=" " />
            </a>
          </xsl:if>
        </td>
        <td>
          <a href="{concat($ServletsBaseURL, 'MCRTileCombineServlet/MID/', $derivid, '/', mcr:encodeURIPath(name))}">
            <img class="previewImageLink" title="{i18n:translate('IFS.preview.image.link')}" />
          </a>
        </td>
      </tr>
      <xsl:if test="$urn or $handle">
        <xsl:if test="$urn">
          <tr>
            <td class="{$rowStyle}">URN: </td>
            <td colspan="7" class="{$rowStyle}">
              <a href="{concat('http://nbn-resolving.de/urn/resolver.pl?urn=', $urn)}">
                <xsl:value-of select="$urn" />
              </a>
            </td>
          </tr>
        </xsl:if>
        <xsl:if test="$handle">
          <tr>
            <td class="{$rowStyle}">Handle: </td>
            <td colspan="7" class="{$rowStyle}">
              <a href="{concat('http://hdl.handle.net/', $handle)}" title="{i18n:translate('IFS.resolveHandle')}">
                <xsl:value-of select="$handle" />
              </a>
            </td>
          </tr>
        </xsl:if>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
