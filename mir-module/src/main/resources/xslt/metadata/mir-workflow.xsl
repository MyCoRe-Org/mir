<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcractionmapping="http://www.mycore.de/xslt/actionmapping"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrurl="http://www.mycore.de/xslt/url"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:modsmeta:metadata/mir-workflow.xsl"/>
  <xsl:import href="xslImport:mirworkflow:metadata/mir-workflow.xsl"/>
  <xsl:import href="mir-pdf-errorbox.xsl"/>
  <xsl:param name="layout" select="'$'"/>
  <xsl:param name="MIR.Workflow.Box" select="'false'"/>
  <xsl:param name="MIR.Workflow.ReviewDerivateRequired" select="'true'"/>
  <xsl:param name="MIR.Sherpa.API.Key" select="''"/>
  <xsl:param name="CurrentUser"/>

  <xsl:param name="MIR.Workflow.Debug" select="'false'"/>
  <xsl:param name="MIR.Workflow.PDFValidation" select="'false'"/>
  <xsl:key use="@id" name="rights" match="/mycoreobject/rights/right"/>
  <xsl:variable name="id" select="/mycoreobject/@ID"/>

  <xsl:include href="resource:xslt/workflow-util.xsl"/>


  <xsl:template match="/">
    <xsl:if test="normalize-space($MIR.Workflow.Box)='true'">
      <div id="mir-workflow" class="col-sm-12">
        <xsl:variable name="statusClassification" select="document('classification:metadata:-1:children:state')"/>
        <xsl:variable name="currentStatus"
                      select="/mycoreobject/service/servstates/servstate[@classid='state']/@categid"/>
        <xsl:variable name="creator" select="/mycoreobject/service/servflags/servflag[@type='createdby']/text()"/>
        <!-- Write -->
        <xsl:choose>
          <xsl:when test="$currentStatus='submitted'">
            <xsl:choose>
              <xsl:when test="mcracl:is-current-user-in-role('editor') or mcracl:is-current-user-in-role('admin')">
                <xsl:apply-templates mode="editorSubmitted"/>
              </xsl:when>
              <xsl:when test="$CurrentUser=$creator">
                <xsl:apply-templates mode="creatorSubmitted"/>
              </xsl:when>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$currentStatus='review'">
            <xsl:choose>
              <xsl:when test="mcracl:is-current-user-in-role('editor') or mcracl:is-current-user-in-role('admin')">
                <xsl:apply-templates mode="editorReview"/>
              </xsl:when>
              <xsl:when test="$CurrentUser=$creator">
                <xsl:apply-templates mode="creatorReview"/>
              </xsl:when>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </div>
    </xsl:if>
    <xsl:apply-imports/>
  </xsl:template>


  <xsl:template match="mycoreobject" mode="creatorSubmitted">
    <xsl:if test="normalize-space($MIR.Workflow.Debug)='true'">
      <xsl:message>
        creatorSubmitted
        Nutzer Ersteller
        Dokument submitted
      </xsl:message>
    </xsl:if>

    <xsl:if test="key('rights', @ID)/@write">
      <xsl:variable name="currentStatus"
                    select="service/servstates/servstate[@classid='state']/@categid"/>
      <xsl:variable name="editURL">
          <xsl:call-template name="getEditURL">
              <xsl:with-param name="id" select="$id" />
          </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="message">
        <p>
          <xsl:value-of select="mcri18n:translate('mir.workflow.creator.submitted')"/>
          <ul>
            <li>
              <a href="{$editURL}">
                <xsl:value-of select="mcri18n:translate('object.editObject')"/>
              </a>
            </li>
            <xsl:apply-templates select="." mode="creatorSubmittedAdd" />
            <xsl:choose>
              <xsl:when test="normalize-space($MIR.Workflow.ReviewDerivateRequired) = 'true' and not(structure/derobjects/derobject/maindoc)">
                <li>
                  <a href="#">
                    <xsl:attribute name="onclick">document.querySelector('[data-upload-object]').scrollIntoView({behavior: 'smooth', block: 'center', inline: 'nearest'}); return false;</xsl:attribute>
                    <xsl:value-of select="mcri18n:translate('mir.workflow.creator.submitted.require.derivate')"/>
                  </a>
                </li>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="listStatusChangeOptions">
                  <xsl:with-param name="class" select="''"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="string-length($MIR.Sherpa.API.Key)&gt;0">
              <xsl:variable name="issn"
                            select="/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/mods:relatedItem/mods:identifier[@type='issn']/text()"/>
              <xsl:if test="string-length($issn)&gt;0">
                <li data-sherpainfo-issn="{$issn}">
                  <xsl:value-of select="mcri18n:translate('mir.workflow.sherpa.loading')" /><span class="spinner-grow spinner-grow-sm" role="status"></span>
                </li>
              </xsl:if>
            </xsl:if>
          </ul>
        </p>
      </xsl:variable>
      <xsl:call-template name="buildLayout">
        <xsl:with-param name="content" select="$message"/>
        <xsl:with-param name="heading" select="''"/>
      </xsl:call-template>
      <xsl:if test="normalize-space($MIR.Workflow.PDFValidation)='true'">
        <xsl:apply-templates select="." mode="displayPdfError"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>


  <xsl:template match="mycoreobject" mode="editorSubmitted" priority="10">
    <xsl:if test="normalize-space($MIR.Workflow.Debug)='true'">
      <xsl:message>
        editorSubmitted
        Nutzer editor
        Dokument submitted
      </xsl:message>
    </xsl:if>

    <xsl:if test="normalize-space($MIR.Workflow.PDFValidation)='true'">
      <xsl:apply-templates select="." mode="displayPdfError"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mycoreobject" mode="creatorReview" priority="10">
    <xsl:if test="normalize-space($MIR.Workflow.Debug)='true'">
      <xsl:message>
        creatorReview
        Nutzer creator
        Dokument review
      </xsl:message>
    </xsl:if>
    <xsl:variable name="message">
      <p>
        <xsl:value-of select="mcri18n:translate('mir.workflow.creator.review')"/>
      </p>
    </xsl:variable>
    <xsl:call-template name="buildLayout">
      <xsl:with-param name="content" select="$message"/>
      <xsl:with-param name="heading" select="''"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mycoreobject" mode="editorReview" priority="10">
    <xsl:if test="normalize-space($MIR.Workflow.Debug)='true'">
      <xsl:message>
        editorReview
        Nutzer editor
        Dokument review
      </xsl:message>
      <xsl:variable name="editURL">
          <xsl:call-template name="getEditURL">
            <xsl:with-param name="id" select="$id" />
          </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="message">
        <p>
          <xsl:value-of select="mcri18n:translate('mir.workflow.editor.review')"/>
          <ul>
            <li>
              <a href="{$editURL}">
                <xsl:value-of select="mcri18n:translate('object.editObject')"/>
              </a>
            </li>
            <xsl:apply-templates select="." mode="editorReviewAdd" />
            <xsl:call-template name="listStatusChangeOptions">
              <xsl:with-param name="class" select="''"/>
            </xsl:call-template>
          </ul>
        </p>
      </xsl:variable>
      <xsl:call-template name="buildLayout">
        <xsl:with-param name="content" select="$message"/>
        <xsl:with-param name="heading" select="''"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>



  <!-- copied from mods.xsl -> ToDo: refacture! -->
  <xsl:template name="mods.getObjectEditURL">
    <xsl:param name="id" />
    <xsl:param name="layout" select="'$'" />
    <xsl:param name="collection" select="''" />
    <xsl:choose>
      <xsl:when test="doc-available('resource:actionmappings.xml')">
        <!-- URL mapping enabled -->
        <xsl:variable name="url">
          <xsl:choose>
            <xsl:when test="string-length($collection) &gt; 0">
              <xsl:choose>
                <xsl:when test="$layout = 'all'">
                  <xsl:value-of select="mcractionmapping:get-url-for-collection('update-xml',$collection,true())" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="mcractionmapping:get-url-for-collection('update',$collection,true())" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$layout = 'all'">
                  <xsl:value-of select="mcractionmapping:get-url-for-id('update-xml',$id,true())" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="mcractionmapping:get-url-for-id('update',$id,true())" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="string-length($url)=0" />
          <xsl:otherwise>
            <xsl:value-of select="mcrurl:set-param($url, 'id', $id)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- URL mapping disabled -->
        <xsl:choose>
          <xsl:when test="$layout != '$'">
            <xsl:value-of select="concat($WebApplicationBaseURL,'/editor/editor-dynamic.xed?id=',$id,'&amp;genre=article&amp;host=standalone')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($WebApplicationBaseURL,'/editor/editor-admin.xed?id=',$id)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  

    <xsl:template name="getEditURL">
        <xsl:param name="id"/>
        <xsl:variable name="adminEditURL">
            <xsl:value-of select="mcractionmapping:get-url-for-id('update-admin',$id,true())"/>
        </xsl:variable>
        <xsl:variable name="normalEditURL">
          <xsl:call-template name="mods.getObjectEditURL">
                <xsl:with-param name="id" select="$id"/>
                <xsl:with-param name="layout" select="$layout"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($adminEditURL)&gt;0">
                <xsl:value-of select="$adminEditURL"/><xsl:text>&amp;id=</xsl:text><xsl:value-of select="$id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$normalEditURL"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="mycoreobject" mode="creatorSubmittedAdd" priority="10">
  </xsl:template>

  <xsl:template match="mycoreobject" mode="editorReviewAdd" priority="10">
  </xsl:template>


  <xsl:template name="buildLayout">
    <xsl:param name="heading"/>
    <xsl:param name="content"/>
    <div class="workflow-box">
      <xsl:if test="string-length(normalize-space($heading))&gt;0">
        <h1>
          <xsl:value-of select="$heading"/>
        </h1>
      </xsl:if>
      <xsl:copy-of select="$content"/>
    </div>
  </xsl:template>
</xsl:stylesheet>
