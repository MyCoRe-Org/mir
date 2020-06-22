<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="3.0">


  <xsl:param name="MIR.Layout.North"/>
  <xsl:param name="MIR.Layout.East"/>
  <xsl:param name="MIR.Layout.West"/>
  <xsl:param name="MIR.Layout.South"/>

  <xsl:param name="MIR.Layout.West.Col" select="'col-12 col-sm-8'"/>
  <xsl:param name="MIR.Layout.East.Col" select="'col-12 col-sm-4'"/>

  <xsl:param name="MIR.Layout.Display.Panel"/>
  <xsl:param name="MIR.Layout.Display.Div"/>

  <xsl:param name="WebApplicationBaseURL"/>


  <xsl:variable name="translations"
                select="document('i18n:mir.metaData.panel.heading.*,component.mods.metaData.dictionary.categorybox,component.mods.metaData.dictionary.*,metadata.versionInfo.label,button.cancel')"/>

  <xsl:template match="/site">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <head>
        <xsl:copy-of select="citation_meta/*"/>
        <link href="{$WebApplicationBaseURL}mir-layout/assets/jquery/plugins/shariff/shariff.min.css" rel="stylesheet"/>
      </head>

      <xsl:copy-of select="document(concat('xslTransform:schemaOrg:mcrobject:', @ID))"/>

      <div class="row top">
        <div class="col-12 north">
          <xsl:call-template name="displayDirection">
            <xsl:with-param name="properties" select="$MIR.Layout.North"/>
          </xsl:call-template>
        </div>
      </div>
      <div class="row middle detail_row">
        <div class="{$MIR.Layout.West.Col} main_col west">
          <xsl:call-template name="displayDirection">
            <xsl:with-param name="properties" select="$MIR.Layout.West"/>
          </xsl:call-template>
        </div>
        <div class="{$MIR.Layout.East.Col} east">
          <xsl:call-template name="displayDirection">
            <xsl:with-param name="properties" select="$MIR.Layout.East"/>
          </xsl:call-template>
        </div>
      </div>
      <div class="row bottom">
        <div class="col-12 south">
          <xsl:call-template name="displayDirection">
            <xsl:with-param name="properties" select="$MIR.Layout.South"/>
          </xsl:call-template>
        </div>
      </div>

      <script src="{$WebApplicationBaseURL}mir-layout/assets/jquery/plugins/shariff/shariff.min.js"></script>
      <script src="{$WebApplicationBaseURL}assets/moment/min/moment.min.js"></script>
      <script src="{$WebApplicationBaseURL}assets/handlebars/handlebars.min.js"></script>
      <script src="{$WebApplicationBaseURL}js/mir/derivate-fileList.min.js"></script>
      <link rel="stylesheet" href="{$WebApplicationBaseURL}rsc/stat/{@ID}.css"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template name="displayDirection">
    <xsl:param name="properties"/>

    <xsl:variable name="originalContent" select="."/>
    <xsl:for-each select="tokenize($properties, ',')">
      <xsl:variable name="boxID" select="normalize-space(.)"/>
      <xsl:if test="count($originalContent/div[@id=$boxID])&gt;=1">
        <!-- this function is bloated due backward compatibility -->
        <xsl:choose>
          <xsl:when test="$boxID='mir-historydata'">
            <div
                id="historyModal"
                class="modal fade"
                tabindex="-1"
                role="dialog"
                aria-labelledby="modal frame"
                aria-hidden="true">
              <div
                  class="modal-dialog modal-lg modal-xl"
                  role="document">
                <div class="modal-content">
                  <div class="modal-header">
                    <h4 class="modal-title" id="modalFrame-title">
                      <xsl:value-of select="$translations/i18n/translation[@key='metadata.versionInfo.label']"/>
                    </h4>
                    <button
                        type="button"
                        class="close modalFrame-cancel"
                        data-dismiss="modal"
                        aria-label="Close">
                      <i class="fas fa-times" aria-hidden="true"></i>
                    </button>
                  </div>
                  <div id="modalFrame-body" class="modal-body">
                    <xsl:copy-of select="$originalContent/div[@id=$boxID]/*"/>
                  </div>
                  <div class="modal-footer">
                    <button
                        id="modalFrame-cancel"
                        type="button"
                        class="btn btn-danger"
                        data-dismiss="modal">
                      <xsl:value-of select="$translations/i18n/translation[@key='button.cancel']"/>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </xsl:when>
          <xsl:when test="$boxID='mir-collapse-files'">
            <div class="detail_block">
              <div id="record_detail">
                <xsl:copy-of select="$originalContent/div[@id=$boxID]/*"/>
              </div>
            </div>
          </xsl:when>
          <xsl:when test="$boxID='mir-admindata'">
            <xsl:if test="$originalContent/@write">
              <div id="mir_admindata_panel" class="card system">
                <div class="card-header">
                  <h3 class="card-title">
                    <xsl:value-of
                        select="$translations/i18n/translation[@key='component.mods.metaData.dictionary.systembox']"/>
                  </h3>
                </div>
                <div class="card-body">
                  <!-- Start: ADMINMETADATA -->
                  <xsl:apply-templates select="$originalContent/div[@id=$boxID]" mode="newMetadata"/>
                  <!-- End: ADMINMETADATA -->
                </div>
              </div>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$boxID='mir-metadata'">
            <div class="mir_metadata">
              <h3>
                <xsl:value-of
                    select="$translations/i18n/translation[@key='component.mods.metaData.dictionary.categorybox']"/>
              </h3>
              <!-- Start: METADATA -->
              <xsl:apply-templates select="$originalContent/div[@id=$boxID]" mode="newMetadata"/>
              <!-- End: METADATA -->
              <xsl:if
                  test="$originalContent/div[@id=$boxID]/table[@class='mir-metadata']/tr/td/div[contains(@class,'openstreetmap-container')]">
                <link rel="stylesheet" type="text/css" href="{$WebApplicationBaseURL}assets/openlayers/ol.css"/>
                <script type="text/javascript" src="{$WebApplicationBaseURL}assets/openlayers/ol.js"/>
                <script type="text/javascript" src="{$WebApplicationBaseURL}js/mir/geo-coords.min.js"></script>
              </xsl:if>
            </div>
          </xsl:when>
          <xsl:when test="contains($MIR.Layout.Display.Panel, $boxID)">
            <div class="card" id="{concat($boxID, '-panel')}">
              <div class="card-header">
                <h3 class="card-title">
                  <xsl:value-of
                      select="$translations/i18n/translation[@key=concat('mir.metaData.panel.heading.', $boxID)]"/>
                </h3>
              </div>
              <div class="card-body">
                <xsl:copy-of select="$originalContent/div[@id=$boxID]/*"/>
              </div>
            </div>
          </xsl:when>
          <xsl:when test="contains($MIR.Layout.Display.Div, $boxID)">
            <div id="{concat($boxID, '-div')}">
              <xsl:copy-of select="$originalContent/div[@id=$boxID]/*"/>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$originalContent/div[@id=$boxID]/*"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <!-- this is spooky ; TODO: Replace-->
  <xsl:template match="div[@id='mir-metadata']" mode="newMetadata">
    <dl>
      <xsl:apply-templates select="table[@class='mir-metadata']/tr" mode="newMetadata"/>
    </dl>
  </xsl:template>
  <xsl:template match="div[@id='mir-admindata']" mode="newMetadata">
    <dl>
      <xsl:apply-templates select=".//div[@id='system_box']/div[@id='system_content']/table/tr" mode="newMetadata"/>
    </dl>
  </xsl:template>
  <xsl:template match="td[@class='metaname']" mode="newMetadata" priority="2">
    <dt>
      <xsl:copy-of select="node()|*"/>
    </dt>
  </xsl:template>
  <xsl:template match="td[@class='metavalue']" mode="newMetadata" priority="2">
    <dd>
      <xsl:copy-of select="node()|*"/>
    </dd>
  </xsl:template>


</xsl:stylesheet>