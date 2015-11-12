<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY html-output SYSTEM "xsl/xsl-output-html.fragment">
]>
<!-- ============================================== -->
<!-- $Revision: 1.21 $ $Date: 2007-11-12 09:37:14 $ -->
<!-- ============================================== -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mcr="http://www.mycore.org/" xmlns:acl="xalan://org.mycore.access.MCRAccessManager" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:xalan="http://xml.apache.org/xalan" exclude-result-prefixes="xlink mcr xalan i18n acl">
  &html-output;
  <xsl:include href="MyCoReLayout.xsl" />
  <!-- include custom templates for supported objecttypes -->
  <xsl:include href="xslInclude:objectTypes"/>
  <xsl:variable name="PageTitle">
    <xsl:apply-templates select="/mycoreobject" mode="pageTitle" />
  </xsl:variable>
  <xsl:param name="resultListEditorID" />
  <xsl:param name="numPerPage" />
  <xsl:param name="page" />
  <xsl:param name="previousObject" />
  <xsl:param name="previousObjectHost" />
  <xsl:param name="nextObject" />
  <xsl:param name="nextObjectHost" />

  <xsl:template match="/mycoreobject" priority="0">
    <xsl:variable name="obj_host">
      <xsl:value-of select="$objectHost" />
    </xsl:variable>

    <!-- Here put in dynamic resultlist -->
    <xsl:apply-templates select="." mode="parent" />
    <xsl:call-template name="resultsub" />
    <xsl:choose>
      <xsl:when test="($obj_host != 'local') or acl:checkPermission(/mycoreobject/@ID,'read')">
        <!-- if access granted: print metadata -->
        <xsl:apply-templates select="." mode="present" />
        <!-- IE Fix for padding and border -->
        <hr />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="i18n:translate('metaData.accessDenied')" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/mycoreobject" mode="pageTitle" priority="0">
    <xsl:value-of select="i18n:translate('metaData.pageTitle')" />
  </xsl:template>

  <xsl:template match="/mycoreobject" mode="parent" priority="0">
    <xsl:variable name="obj_host">
      <xsl:value-of select="$objectHost" />
    </xsl:variable>
    <xsl:if test="./structure/parents">
      <div id="parent">
        <!-- Pay a little attention to this !!! -->
        <xsl:apply-templates select="./structure/parents">
          <xsl:with-param name="obj_host" select="$obj_host" />
          <xsl:with-param name="obj_type" select="'this'" />
        </xsl:apply-templates>
        &#160;&#160;
        <xsl:apply-templates select="./structure/parents">
          <xsl:with-param name="obj_host" select="$obj_host" />
          <xsl:with-param name="obj_type" select="'before'" />
        </xsl:apply-templates>
        &#160;&#160;
        <xsl:apply-templates select="./structure/parents">
          <xsl:with-param name="obj_host" select="$obj_host" />
          <xsl:with-param name="obj_type" select="'after'" />
        </xsl:apply-templates>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/mycoreobject" mode="present" priority="0">
    <xsl:variable name="objectType" select="substring-before(substring-after(@ID,'_'),'_')" />
    <xsl:value-of select="i18n:translate('metaData.noTemplate')" />
    <form method="get" style="padding:20px;background-color:yellow">
      <fieldset>
        <legend>Automatisches Erzeugen von Vorlagen</legend>
        <table>
          <tr>
            <td>
              <label>Was erzeugen?</label>
            </td>
            <td>
              <select name="XSL.Style">
                <option value="generateMessages">messages_*.properties Vorlage</option>
                <option value="generateStylesheet">
                  <xsl:value-of select="concat($objectType,'.xsl Vorlage')" />
                </option>
              </select>
            </td>
          </tr>
        </table>
      </fieldset>
      <fieldset>
        <legend>
          <xsl:value-of select="concat('Optionen für Erzeugen von ',$objectType,'.xsl')" />
        </legend>
        <table>
          <tr>
            <td>
              <label>Objekt kann Derivate enthalten</label>
            </td>
            <td>
              <input type="checkbox" name="XSL.withDerivates" />
            </td>
          </tr>
          <tr>
            <td>
              <label>Unterstützung für IView</label>
            </td>
            <td>
              <input type="checkbox" name="XSL.useIView" />
            </td>
          </tr>
          <tr>
            <td>
              <label>Kindobjekttypen</label>
            </td>
            <td>
              <input name="XSL.childObjectTypes" />
              (durch Leerzeichen getrennt)
            </td>
          </tr>
        </table>
      </fieldset>
      <input type="submit" value="erstellen" />
    </form>
    <xsl:variable name="objectBaseURL">
      <xsl:if test="$objectHost != 'local'">
        <xsl:value-of select="document('webapp:hosts.xml')/mcr:hosts/mcr:host[@alias=$objectHost]/mcr:url[@type='object']/@href" />
      </xsl:if>
      <xsl:if test="$objectHost = 'local'">
        <xsl:value-of select="concat($WebApplicationBaseURL,'receive/')" />
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="staticURL">
      <xsl:value-of select="concat($objectBaseURL,@ID)" />
    </xsl:variable>
  </xsl:template>

  <!-- Generates a header for the metadata output -->
  <xsl:template name="resultsub">
    <table id="metaHeading" cellpadding="0" cellspacing="0">
      <tr>
        <td class="titles">
          <xsl:apply-templates select="." mode="title" />
        </td>
        <td class="browseCtrl">
          <xsl:call-template name="browseCtrl" />
        </td>
      </tr>
    </table>
    <!-- IE Fix for padding and border -->
    <hr />
  </xsl:template>

  <xsl:template name="browseCtrl">
    <xsl:if test="string-length($previousObject)>0">
      <xsl:variable name="hostParam">
        <xsl:if test="$previousObjectHost != 'local'">
          <xsl:value-of select="concat('?host=',$previousObjectHost)" />
        </xsl:if>
      </xsl:variable>
      <a href="{$WebApplicationBaseURL}receive/{$previousObject}{$HttpSession}{$hostParam}">&lt;&lt;</a>
      &#160;&#160;
    </xsl:if>
    <xsl:if test="string-length($numPerPage)>0">
      <a
        href="{$ServletsBaseURL}MCRSearchServlet{$HttpSession}?mode=results&amp;id={$resultListEditorID}&amp;page={$page}&amp;numPerPage={$numPerPage}">
        ^
    </a>
    </xsl:if>
    <xsl:if test="string-length($nextObject)>0">
      <xsl:variable name="hostParam">
        <xsl:if test="$nextObjectHost != 'local'">
          <xsl:value-of select="concat('?host=',$nextObjectHost)" />
        </xsl:if>
      </xsl:variable>
      &#160;&#160;
      <a href="{$WebApplicationBaseURL}receive/{$nextObject}{$HttpSession}{$hostParam}">&gt;&gt;</a>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/mycoreobject" mode="title" priority="0">
    <xsl:value-of select="@ID" />
  </xsl:template>

  <xsl:template match="/mycoreobject" mode="resulttitle" priority="0">
    <xsl:value-of select="@ID" />
  </xsl:template>

  <!-- Internal link from Derivate ********************************* -->
  <xsl:template match="internals">
    <xsl:if test="$objectHost = 'local'">
      <xsl:variable name="obj_host" select="../../../@host" />
      <xsl:variable name="derivid" select="../../@ID" />
      <xsl:variable name="derivlabel" select="../../@label" />
      <xsl:variable name="derivmain" select="internal/@maindoc" />
      <xsl:variable name="derivbase" select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derivid,'/')" />
      <xsl:variable name="derivifs" select="concat($derivbase,$derivmain,$HttpSession)" />
      <xsl:variable name="derivdir" select="concat($derivbase,$HttpSession)" />
      <xsl:variable name="derivxml" select="concat('ifs:/',$derivid)" />
      <xsl:variable name="details" select="document($derivxml)" />
      <xsl:variable name="ctype" select="$details/mcr_directory/children/child[name=$derivmain]/contentType" />
      <xsl:variable name="ftype" select="document('webapp:FileContentTypes.xml')/FileContentTypes/type[@ID=$ctype]/label" />
      <xsl:variable name="size" select="$details/mcr_directory/size" />
      <div class="derivateHeading">
        <xsl:choose>
          <xsl:when test="../titles">
            <xsl:call-template name="printI18N">
              <xsl:with-param name="nodes" select="../titles/title" />
              <xsl:with-param name="next" select="'&lt;br /&gt;'" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$derivlabel" />
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <div class="derivate">
        <a href="{$derivifs}" target="_blank">
          <xsl:value-of select="$derivmain" />
        </a>
        (
        <xsl:value-of select="ceiling(number($size) div 1024)" />
        &#160;kB) &#160;&#160;
        <xsl:variable name="ziplink" select="concat($ServletsBaseURL,'MCRZipServlet',$JSessionID,'?id=',$derivid)" />
        <a class="linkButton" href="{$ziplink}">
          <xsl:value-of select="i18n:translate('buttons.zipGen')" />
        </a>
        &#160;
        <a href="{$derivdir}">
          <xsl:value-of select="i18n:translate('buttons.details')" />
        </a>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- External link from Derivate ********************************* -->
  <xsl:template match="externals">
    <div class="derivateHeading">
      <xsl:value-of select="i18n:translate('metaData.link')" />
    </div>
    <div class="derivate">
      <xsl:call-template name="webLink">
        <xsl:with-param name="nodes" select="external" />
      </xsl:call-template>
    </div>
  </xsl:template>

  <!-- Link to the parent ****************************************** -->
  <xsl:template match="parents">
    <xsl:param name="obj_host" select="$objectHost" />
    <xsl:param name="obj_type" />
    <xsl:variable name="hostParam">
      <xsl:if test="$obj_host != 'local'">
        <xsl:value-of select="concat('?host=',$obj_host)" />
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="thisid">
      <xsl:value-of select="../../@ID" />
    </xsl:variable>
    <xsl:variable name="parent">
      <xsl:if test="$obj_host = 'local'">
        <xsl:copy-of select="document(concat('mcrobject:',parent/@xlink:href))/mycoreobject" />
      </xsl:if>
      <xsl:if test="$obj_host != 'local'">
        <xsl:copy-of
          select="document(concat('mcrws:operation=MCRDoRetrieveObject&amp;host=',$obj_host,'&amp;ID=',parent/@xlink:href))/mycoreobject" />
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="parent" select="xalan:nodeset($parent)" />
    <xsl:choose>
      <xsl:when test="$obj_type = 'this'">
        <xsl:call-template name="objectLink">
          <xsl:with-param name="obj_id" select="parent/@xlink:href" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$obj_type = 'before'">
        <xsl:variable name="pos">
          <xsl:for-each select="$parent/structure/children/child">
            <xsl:sort select="." />
            <xsl:variable name="child">
              <xsl:value-of select="@xlink:href" />
            </xsl:variable>
            <xsl:if test="$thisid = $child">
              <xsl:value-of select="position()" />
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="$parent/structure/children/child">
          <xsl:sort select="." />
          <xsl:variable name="child">
            <xsl:value-of select="@xlink:href" />
          </xsl:variable>
          <xsl:if test="position() = $pos - 1">
            <a href="{$WebApplicationBaseURL}receive/{$child}{$HttpSession}{$hostParam}">
              &#60;--
            </a>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$obj_type = 'after'">
        <xsl:variable name="pos">
          <xsl:for-each select="$parent/structure/children/child">
            <xsl:sort select="." />
            <xsl:variable name="child">
              <xsl:value-of select="@xlink:href" />
            </xsl:variable>
            <xsl:if test="$thisid = $child">
              <xsl:value-of select="position()" />
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="$parent/structure/children/child">
          <xsl:sort select="." />
          <xsl:variable name="child">
            <xsl:value-of select="@xlink:href" />
          </xsl:variable>
          <xsl:if test="position() = $pos + 1">
            <a href="{$WebApplicationBaseURL}receive/{$child}{$HttpSession}{$hostParam}">
              --&#62; </a>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Work with the children ************************************** -->
  <xsl:template match="children">
    <ul>
      <xsl:for-each select="child">
        <xsl:sort select="concat(@xlink:title,@xlink:label)" />
        <li>
          <xsl:apply-templates select="." />
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <!-- Link to the child ******************************************* -->
  <xsl:template match="child">
    <xsl:call-template name="objectLink">
      <xsl:with-param name="obj_id" select="@xlink:href" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mycoreobject" mode="versioninfo">
    <xsl:variable name="verinfo" select="document(concat('versioninfo:',@ID))" />
    <ol class="versioninfo">
      <xsl:for-each select="$verinfo/versions/version">
        <xsl:sort order="descending" select="position()" data-type="number" />
        <li>
          <xsl:if test="@r">
            <xsl:variable name="href">
              <xsl:call-template name="UrlSetParam">
                <xsl:with-param name="url" select="$RequestURL" />
                <xsl:with-param name="par" select="'r'" />
                <xsl:with-param name="value" select="@r" />
              </xsl:call-template>
            </xsl:variable>
            <span class="rev">
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
            </span>
            <xsl:value-of select="' '" />
          </xsl:if>
          <xsl:if test="@action">
            <span class="action">
              <xsl:value-of select="i18n:translate(concat('metaData.versions.action.',@action))" />
            </span>
            <xsl:value-of select="' '" />
          </xsl:if>
          <span class="@date">
            <xsl:call-template name="formatISODate">
              <xsl:with-param name="date" select="@date" />
              <xsl:with-param name="format" select="i18n:translate('metaData.dateTime')" />
            </xsl:call-template>
          </span>
          <xsl:value-of select="' '" />
          <xsl:if test="@user">
            <span class="user">
              <xsl:value-of select="@user" />
            </span>
            <xsl:value-of select="' '" />
          </xsl:if>
        </li>
      </xsl:for-each>
    </ol>
  </xsl:template>

</xsl:stylesheet>