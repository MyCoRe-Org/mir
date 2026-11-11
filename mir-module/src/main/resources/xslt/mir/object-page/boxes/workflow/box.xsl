<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcractionmapping="http://www.mycore.de/xslt/actionmapping"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:modsmeta:mir/object-page/boxes/workflow/box.xsl"/>
  <xsl:import href="xslImport:mirworkflow"/>
  <xsl:import href="pdf-error.xsl"/>
  <xsl:param name="MIR.Workflow.Box" select="'false'"/>
  <xsl:param name="MIR.Workflow.ReviewDerivateRequired" select="'true'"/>
  <xsl:param name="CurrentUser"/>

  <xsl:param name="MIR.Workflow.Debug" select="'false'"/>
  <xsl:param name="MIR.Workflow.PDFValidation" select="'false'"/>
  <xsl:key use="@id" name="rights" match="/mycoreobject/rights/right"/>
  <xsl:variable name="id" select="/mycoreobject/@ID"/>

  <xsl:include href="resource:xslt/mir/object-page/boxes/workflow/utils.xsl"/>


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
    </xsl:if>
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
  </xsl:template>



  

    <xsl:template name="getEditURL">
        <xsl:param name="id"/>
        <xsl:variable name="admin-edit-url">
            <xsl:value-of select="mcractionmapping:get-url-for-id('update-admin',$id,true())"/>
        </xsl:variable>
        <xsl:variable name="normal-edit-url" select="mirobject:edit-url($id)"/>
        <xsl:choose>
            <xsl:when test="string-length($admin-edit-url)&gt;0">
                <xsl:value-of select="$admin-edit-url"/><xsl:text>&amp;id=</xsl:text><xsl:value-of select="$id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$normal-edit-url"/>
            </xsl:otherwise>
        </xsl:choose>
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
