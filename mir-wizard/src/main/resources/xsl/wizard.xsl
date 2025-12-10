<?xml version="1.0" encoding="utf-8"?>
  <!-- ============================================== -->
  <!-- $Revision$ $Date$ -->
  <!-- ============================================== -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="i18n xlink"
>
  <xsl:include href="MyCoReLayout.xsl" />
  <xsl:strip-space elements="*" />

  <xsl:variable name="PageTitle" select="i18n:translate('component.mir.wizard.title')" />

  <xsl:template match="wizard">
    <head>
      <link rel="stylesheet" href="{$WebApplicationBaseURL}mir-wizard/assets/highlightjs/css/default.css" />
      <script src="{$WebApplicationBaseURL}mir-wizard/assets/highlightjs/js/highlight.js"></script>
    </head>
    <xsl:apply-templates />
    <script type="text/javascript">
      hljs.initHighlightingOnLoad();
    </script>
  </xsl:template>

  <xsl:template match="results">
    <xsl:for-each select="./*">
      <xsl:variable name="statusClass">
        <xsl:choose>
          <xsl:when test="@success = 'true'">
            <xsl:text>bg-success</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>bg-danger</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="(name(.) = 'download' and string-length(@lib) &gt; 0) or (name(.) != 'download')">
        <fieldset>
          <legend>
            <xsl:choose>
              <xsl:when test="name() = 'download'">
                <xsl:value-of select="i18n:translate('component.mir.wizard.downloaded.lib', @lib)" />
              </xsl:when>
              <xsl:when test="name() = 'init.database'">
                <xsl:value-of select="i18n:translate('component.mir.wizard.initDatabase')" />
              </xsl:when>
              <xsl:when test="name() = 'init.superuser'">
                <xsl:value-of select="i18n:translate('component.mir.wizard.initSuperuser')" />
              </xsl:when>
              <xsl:when test="name() = 'load.classifications'">
                <xsl:value-of select="i18n:translate('component.mir.wizard.loadClassifications')" />
              </xsl:when>
              <xsl:when test="name() = 'import.acls'">
                <xsl:value-of select="i18n:translate('component.mir.wizard.importACLs')" />
              </xsl:when>
              <xsl:when test="name() = 'import.webacls'">
                <xsl:value-of select="i18n:translate('component.mir.wizard.importWebACLs')" />
              </xsl:when>
              <xsl:when test="name() = 'import.restapiacls'">
                <xsl:value-of select="i18n:translate('component.mir.wizard.importRestApiACLs')" />
              </xsl:when>
              <xsl:when test="name() = 'solr'">
                <xsl:value-of select="i18n:translate('component.mir.wizard.installSolrHome')" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="@file">
                  <xsl:value-of select="i18n:translate('component.mir.wizard.generated.file', name(.))" />
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
            <span class="float-end badge {$statusClass}">
              <xsl:value-of select="i18n:translate(concat('component.mir.wizard.status.', @success))" />
            </span>
          </legend>
          <xsl:choose>
            <xsl:when test="name() = 'download'">
            </xsl:when>
            <xsl:otherwise>
              <pre class="pre-scrollable">
                <code>
                  <xsl:apply-templates select="result" />
                </code>
              </pre>
            </xsl:otherwise>
          </xsl:choose>
        </fieldset>
      </xsl:if>
    </xsl:for-each>

    <xsl:if test="@success = 'true'">
      <div class="modal fade" id="confirm-shutdown" tabindex="-1" role="dialog" aria-labelledby="confirmTitle" aria-hidden="true">
        <div class="modal-dialog">
          <div class="modal-content">

            <div class="modal-header">
              <h4 class="modal-title" id="confirmTitle">
                <xsl:value-of select="i18n:translate('component.mir.wizard.shutdownServer.confirmTitle')" />
              </h4>
              <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" />
            </div>

            <div class="modal-body">
              <p>
                <xsl:value-of select="i18n:translate('component.mir.wizard.shutdownServer.confirmMessage')" />
              </p>
            </div>

            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                <xsl:value-of select="i18n:translate('component.mir.wizard.cancel')" />
              </button>
              <a href="{$ServletsBaseURL}MIRWizardServlet/shutdown" class="btn btn-danger danger">
                <xsl:value-of select="i18n:translate('component.mir.wizard.shutdownServer')" />
              </a>
            </div>
          </div>
        </div>
      </div>
      <br />
      <a class="btn btn-primary float-end" data-bs-toggle="modal" data-bs-target="#confirm-shutdown" href="#">
        <xsl:value-of select="i18n:translate('component.mir.wizard.shutdownServer')" />
      </a>
      <br />
    </xsl:if>
  </xsl:template>

  <xsl:template match="result">
    <xsl:apply-templates mode="escaped" />
  </xsl:template>

  <xsl:template match="*" mode="escaped">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()" />
    <xsl:apply-templates select="@*" mode="escaped" />

    <xsl:choose>
      <xsl:when test="(count(./*) = 0) and (string-length(text()) = 0)">
        <xsl:text> /&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&gt;</xsl:text>

        <xsl:if test="(count(./*) &gt; 1) or (count(./*/*) &gt; 1)">
          <xsl:text>&#13;</xsl:text>
        </xsl:if>

        <xsl:apply-templates select="node()" mode="escaped" />
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="name()" />
        <xsl:text>&gt;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:text>&#13;</xsl:text>
  </xsl:template>

  <xsl:template match="@*" mode="escaped">
    <xsl:text>&#32;</xsl:text>
    <xsl:value-of select="name()" />
    <xsl:text>="</xsl:text>
    <xsl:value-of select="." />
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="text()" mode="escaped">
    <xsl:value-of select="." />
  </xsl:template>
</xsl:stylesheet>
