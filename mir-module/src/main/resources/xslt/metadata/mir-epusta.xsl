<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:modsmeta:metadata/mir-epusta.xsl" />

  <xsl:param name="MIR.ePuSta" select="'hide'" />
  <xsl:param name="MIR.ePuSta.Prefix" />
  <xsl:param name="MIR.ePuSta.GraphProviderURL" />

  <xsl:template match="/">
    <xsl:if test="$MIR.ePuSta = 'show'">
      <xsl:variable name="ID" select="/mycoreobject/@ID" />
      <xsl:variable name="now" select="current-dateTime()"/>
      <xsl:variable name="now-1year">
        <xsl:choose>
          <xsl:when test="month-from-dateTime($now) = 2 and day-from-dateTime($now) = 29">
            <xsl:value-of select="concat(year-from-dateTime($now)-1,'-02-28')" />
          </xsl:when>
          <xsl:when test="month-from-dateTime($now) &gt; 9 and day-from-dateTime($now) &gt; 9">
            <xsl:value-of select="concat(year-from-dateTime($now)-1,'-',month-from-dateTime($now),'-',day-from-dateTime($now))" />
          </xsl:when>
          <xsl:when test="month-from-dateTime($now) &gt; 9 ">
            <xsl:value-of select="concat(year-from-dateTime($now)-1,'-',month-from-dateTime($now),'-0',day-from-dateTime($now))" />
          </xsl:when>
          <xsl:when test="day-from-dateTime($now) &gt; 9">
            <xsl:value-of select="concat(year-from-dateTime($now)-1,'-0',month-from-dateTime($now),'-',day-from-dateTime($now))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat(year-from-dateTime($now)-1,'-0',month-from-dateTime($now),'-0',day-from-dateTime($now))" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="from" select="$now-1year" />
      <xsl:variable name="until" select="format-dateTime($now, '[Y0001]-[M01]-[D01]')" />
      <xsl:variable name="objID" select="mycoreobject/@ID" />
      <div id="mir-epusta">
        <div class="card">
          <div class="card-header d-flex justify-content-between align-items-center">
            <h3 class="card-title">
              <xsl:value-of select="mcri18n:translate('mir.epusta.panelheading')" />
            </h3>
            <img src="{$WebApplicationBaseURL}images/epusta/epustalogo_small.png" class="mir-epusta-logo" />
          </div>
          <div class="card-body">
            <span>
              <strong>
                <xsl:value-of select="concat(mcri18n:translate('mir.epusta.total'),':')" />
              </strong>
            </span>
            <div class="row">
              <div class="col-md-7 col-sm-9 col-6 text-end">
                <xsl:value-of select="mcri18n:translate('mir.epusta.counter.fulltext')" />
              </div>
              <div
                  data-epustaelementtype="ePuStaInline"
                  data-epustaproviderurl="{$MIR.ePuSta.GraphProviderURL}"
                  data-epustaidentifier="{$MIR.ePuSta.Prefix}{$objID}"
                  data-epustacounttype="counter"
              />
            </div>
            <div class="row">
              <div class="col-md-7 col-sm-9 col-6 text-end">
                <xsl:value-of select="mcri18n:translate('mir.epusta.counter.abstract')" />
              </div>
              <div
                  data-epustaelementtype="ePuStaInline"
                  data-epustaproviderurl="{$MIR.ePuSta.GraphProviderURL}"
                  data-epustaidentifier="{$MIR.ePuSta.Prefix}{$objID}"
                  data-epustacounttype="counter_abstract"
              />
            </div>
            <span>
              <strong>
                <xsl:value-of select="concat(mcri18n:translate('mir.epusta.last12Month'),':')" />
              </strong>
            </span>
            <div class="row">
              <div class="col-md-7 col-sm-9 col-6 text-end">
                <xsl:value-of select="mcri18n:translate('mir.epusta.counter.fulltext')" />
              </div>
              <div
                  data-epustaelementtype="ePuStaInline"
                  data-epustaproviderurl="{$MIR.ePuSta.GraphProviderURL}"
                  data-epustaidentifier="{$MIR.ePuSta.Prefix}{$objID}"
                  data-epustacounttype="counter"
                  data-epustafrom="{$from}" data-epustauntil="{$until}"
              />
            </div>
            <div class="row">
              <div class="col-md-7 col-sm-9 col-6 text-end">
                <xsl:value-of select="mcri18n:translate('mir.epusta.counter.abstract')" />
              </div>
              <div data-epustaelementtype="ePuStaInline"
                   data-epustaproviderurl="{$MIR.ePuSta.GraphProviderURL}"
                   data-epustaidentifier="{$MIR.ePuSta.Prefix}{$objID}"
                   data-epustacounttype="counter_abstract"
                   data-epustafrom="{$from}" data-epustauntil="{$until}"
              />
            </div>
            <div class="text-end">
              <a href="#" data-bs-toggle="modal" data-target="#epustaGraphModal">
                <xsl:value-of select="mcri18n:translate('mir.epusta.open')" />
              </a>
            </div>
            <div
              class="modal fade"
              id="epustaGraphModal"
              tabindex="-1"
              role="dialog"
              aria-labelledby="epustaGraphTitel"
              aria-hidden="true">
              <div class="modal-dialog" role="document">
                <div class="modal-content">
                  <div class="modal-header">
                    <h4 class="modal-title " id="epustaGraphTitel">
                      <xsl:value-of select="mcri18n:translate('mir.epusta.panelheading')" />
                    </h4>
                    <button
                      type="button"
                      class="close modalFrame-cancel"
                      data-bs-dismiss="modal"
                      aria-label="Close">
                      <i class="fas fa-times" aria-hidden="true"></i>
                    </button>
                  </div>
                  <div class="modal-body">
                    <div id="epustaGraph" class="mir-epusta-graph"
                        data-epustaelementtype="EPuStaGraph"
                        data-epustaproviderurl="{$MIR.ePuSta.GraphProviderURL}"
                        data-epustaidentifier="{$MIR.ePuSta.Prefix}{$objID}"
                        data-epustafrom="{$from}" data-epustauntil="{$until}">
                    </div>
                  </div>
                  <div class="modal-footer">
                    <img
                      src="{$WebApplicationBaseURL}images/epusta/epustalogo.png"
                      class="mir-epusta-logo" />
                  </div>
                </div>
              </div>
            </div>
            <script src="{$MIR.ePuSta.GraphProviderURL}includes/raphael-2.1.2/raphael-min.js"></script>
            <script src="{$MIR.ePuSta.GraphProviderURL}includes/morris.js-0.5.1/morris.js"></script>
            <script src="{$WebApplicationBaseURL}js/epusta.min.js" ></script>
            <style type="text/css">
              @import url("<xsl:value-of select="$MIR.ePuSta.GraphProviderURL" />includes/morris.js-0.5.1/morris.css");
            </style>
          </div>
        </div>
      </div>
    </xsl:if>
    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>
