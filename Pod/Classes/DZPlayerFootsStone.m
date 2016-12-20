//
//  DZPlayerFootsStone.m
//  Pods
//
//  Created by baidu on 2016/12/20.
//
//

#import "DZPlayerFootsStone.h"

#import "DZPlayerGlobalContext.h"
#import "avformat.h"
#import "swscale.h"
#import "imgutils.h"

#define DZPlayerError -1
#define DZPlayerSuccess 0

@interface DZPlayerFootsStone ()
{
    AVFormatContext* _pFormatCtx;
    AVCodecContext * _pCodeCtx;
    int _videoStream;
}
@end

@implementation DZPlayerFootsStone
- (instancetype) init
{
    self = [super init];
    if (!self) {
        return self;
    }
    DZPlayerGlobalContextInit();
    // share init
    _pFormatCtx = NULL;
    return self;
}

- (instancetype) initWithURL:(NSURL *)url
{
    self = [(NSObject*)self init];
    if (!self) {
        return self;
    }
    _url = url;
    return self;
}

- (int) setupLocalContext
{
    if (_pFormatCtx != NULL) {
        return DZPlayerSuccess;
    }
    if(avformat_open_input(&_pFormatCtx, _url.absoluteString.UTF8String, NULL, NULL) != DZPlayerSuccess ) {
        return DZPlayerError;
    }
    if (avformat_find_stream_info(_pFormatCtx, NULL) < 0) {
        return DZPlayerError;
    }
#ifdef DEBUG
    av_dump_format(_pFormatCtx, 0, _url.absoluteString.UTF8String, 0);
#endif
    
    AVCodecContext * pCodeCtx = NULL;
    int videoStream = DZPlayerError;
    for (int i = 0; i < _pFormatCtx->nb_streams; i++) {
        if (_pFormatCtx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            videoStream = i;
            break;
        }
    }
    if (videoStream == DZPlayerError) {
        return DZPlayerError;
    }
    _videoStream = videoStream;
    pCodeCtx = _pFormatCtx->streams[videoStream]->codecpar;
    
    AVCodec* pCodec = NULL;
    pCodec = avcodec_find_encoder(pCodeCtx->codec_id);
    if (pCodec == NULL) {
        return DZPlayerError;
    }
    
    AVCodecContext * pCodecCtxOrig = NULL;
    pCodeCtx = avcodec_alloc_context3(pCodec);
    if (avcodec_parameters_copy(pCodeCtx, pCodecCtxOrig) != DZPlayerSuccess) {
        return DZPlayerError;
    }
    
    if (avcodec_open2(pCodeCtx, pCodec, NULL) < 0) {
        return DZPlayerError;
    }
    

    

    _pCodeCtx = pCodeCtx;
    return DZPlayerSuccess;
}

- (int) play {
    if (![self setupLocalContext]) {
        return DZPlayerError;
    }

    return DZPlayerSuccess;
}

- (int) read_packet
{
    AVPacket packet;
    struct SwsContext* sws_ctx = NULL;
    int frameFinished;
    
    AVFrame* pFrameRGB = NULL;
    if (pFrameRGB == NULL) {
        return DZPlayerError;
    }
    
    uint8_t* buffer = NULL;
    int numBytes = 0;
    numBytes = avpicture_get_size(AV_PIX_FMT_RGB24, _pCodeCtx->width, _pCodeCtx->height);
    buffer = (uint8_t*)av_malloc(numBytes*sizeof(uint8_t));
    avpicture_fill((AVPicture*)pFrameRGB, buffer, AV_PIX_FMT_RGB24, _pCodeCtx->width, _pCodeCtx->height);
    sws_ctx = sws_getContext(_pCodeCtx->width,
                             _pCodeCtx->height,
                             _pCodeCtx->pix_fmt,
                             _pCodeCtx->width,
                             _pCodeCtx->height,
                             AV_PIX_FMT_RGB24,
                             SWS_BILINEAR,
                             NULL,
                             NULL,
                             NULL);
    
    int i = 0;
    AVFrame* pFrame = NULL;
    pFrame = av_frame_alloc();
    while (av_read_frame(_pFormatCtx, &packet)> 0) {
        if (packet.stream_index == _videoStream) {
            avcodec_decode_video2(_pCodeCtx, pFrame, &frameFinished, &packet);
            if (frameFinished) {
                sws_scale(sws_ctx, pFrame->data, pFrame->linesize, 0, _pCodeCtx->height, pFrameRGB->priv_data, pFrameRGB->linesize);
                
            }
        }
    }
}
@end
